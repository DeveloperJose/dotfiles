#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$SCRIPT_DIR}"
TARGET_DIR="${TARGET_DIR:-$HOME}"
BACKUP_ROOT="${BACKUP_ROOT:-$HOME/.dotfiles_backups}"
HOST="${HOSTNAME:-$(hostnamectl hostname 2>/dev/null || hostname 2>/dev/null || echo unknown)}"

DRY_RUN=0
RESTOW=1
BACKUP=1
SYSTEM=0
BOOTSTRAP=1
REQUESTED_PACKAGES=()
TREE_SITTER_CLI_VERSION="${TREE_SITTER_CLI_VERSION:-0.25.10}"

# One shared recovery list for every distro. Names are translated per package
# manager only where distributions disagree.
SHARED_PACKAGES=(
    curl       # HTTP client used by installers and scripts.
    fastfetch  # System summary shown in interactive shells.
    fd         # Fast file finder.
    fish       # Default interactive shell.
    git        # Version control and dotfiles checkout.
    lazygit    # Terminal UI for Git.
    less       # Pager for logs, man output, and Git.
    make       # Common build tool for source installs.
    openssh    # SSH client/server tools; mapped to openssh-client on Debian.
    ripgrep    # Fast text search.
    rsync      # File sync/copy tool.
    starship   # Cross-shell prompt.
    stow       # Dotfile symlink manager.
    tmux       # Terminal multiplexer.
    tree       # Directory tree viewer.
    unzip      # Zip archive extraction.
    wget       # Downloader used by some installers.
)

# Arch desktop recovery, not a snapshot of every currently installed package.
ARCH_DESKTOP_PACKAGES=(
    amd-ucode                 # AMD CPU microcode for early boot.
    amdgpu_top                # AMD GPU monitoring.
    btrfs-progs               # Btrfs filesystem tools.
    cliphist                  # Wayland clipboard history.
    dms-shell                 # DankMaterialShell desktop shell.
    dms-shell-niri            # DMS integration for niri.
    docker                    # Container engine.
    docker-buildx             # Docker BuildKit/buildx plugin.
    docker-compose            # Docker Compose plugin.
    egl-wayland               # EGL support for Wayland clients.
    firefox                   # Browser.
    foot                      # Wayland terminal.
    fuzzel                    # Wayland app launcher.
    greetd                    # Login/session daemon.
    grim                      # Wayland screenshot tool.
    grub                      # Bootloader.
    jq                        # JSON processor.
    linux                     # Arch kernel.
    linux-firmware            # Device firmware.
    linux-headers             # Kernel headers for DKMS/builds.
    mesa-utils                # Mesa/OpenGL diagnostic tools.
    networkmanager            # Network management daemon and CLI.
    niri                      # Scrollable Wayland compositor.
    noto-fonts                # General Noto font family.
    noto-fonts-cjk            # CJK font coverage.
    noto-fonts-emoji          # Emoji font coverage.
    pacman-contrib            # Pacman helpers such as paccache.
    pipewire                  # Media server core.
    pipewire-alsa             # ALSA compatibility for PipeWire.
    pipewire-audio            # PipeWire audio session components.
    pipewire-pulse            # PulseAudio compatibility for PipeWire.
    polkit-gnome              # Polkit authentication agent.
    qt5-wayland               # Qt5 Wayland support.
    qt5ct                     # Qt5 theme/config tool.
    qt6-multimedia-ffmpeg     # Qt6 multimedia FFmpeg backend.
    qt6-wayland               # Qt6 Wayland support.
    reflector                 # Arch mirrorlist updater.
    slurp                     # Wayland region selector.
    ttf-dejavu                # DejaVu TrueType fonts.
    ttf-liberation            # Microsoft-compatible metric fonts.
    uwsm                      # User Wayland session manager.
    vulkan-radeon             # Radeon Vulkan driver.
    vulkan-tools              # Vulkan diagnostic tools.
    wireplumber               # PipeWire session manager.
    wl-clipboard              # Wayland clipboard CLI tools.
    xwayland-satellite        # Xwayland support for niri.
    zathura                   # PDF/document viewer.
    zathura-pdf-mupdf         # PDF backend for zathura.
    zoxide                    # Smarter cd command.
)

ARCH_DESKTOP_AUR_PACKAGES=(
    cpptrace                # Runtime library needed by quickshell on this setup.
    dsearch-bin             # Dank filesystem search service.
    greetd-dms-greeter-git  # DMS greeter for greetd.
    quickshell-git          # QtQuick shell runtime used by DMS.
    qt6ct-kde               # Qt6 config tool variant expected by DMS.
)

usage() {
    cat <<'USAGE'
Usage: ./sync.sh [options] [package ...]

Options:
  -n, --dry-run      Show what would happen without changing files.
  --no-backup        Do not move conflicting files out of the way.
  --no-bootstrap     Skip package installation and fish shell setup.
  --no-restow        Run stow normally instead of restow.
  --system           Stow system packages into / instead of home packages.
  -h, --help         Show this help.

With no package arguments, stow packages are selected by hostname:
  arch-desktop gets shared + arch-desktop, vps can get shared + vps if that
  package exists, and every other host gets shared only.

System packages target / and usually need sudo:
  sudo ./sync.sh --system
USAGE
}

while (($#)); do
    case "$1" in
        -n|--dry-run)
            DRY_RUN=1
            ;;
        --no-backup)
            BACKUP=0
            ;;
        --no-bootstrap)
            BOOTSTRAP=0
            ;;
        --no-restow)
            RESTOW=0
            ;;
        --system)
            SYSTEM=1
            BOOTSTRAP=0
            TARGET_DIR=/
            BACKUP_ROOT="${SYSTEM_BACKUP_ROOT:-$HOME/.dotfiles_system_backups}"
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            REQUESTED_PACKAGES+=("$@")
            break
            ;;
        -*)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
        *)
            REQUESTED_PACKAGES+=("$1")
            ;;
    esac
    shift
done

run_cmd() {
    if ((DRY_RUN)); then
        printf 'DRY-RUN:'
        printf ' %q' "$@"
        printf '\n'
    else
        "$@"
    fi
}

sudo_cmd() {
    if [[ $EUID -eq 0 ]]; then
        run_cmd "$@"
    elif command -v sudo >/dev/null 2>&1; then
        run_cmd sudo "$@"
    else
        echo "sudo is required to run: $*" >&2
        return 1
    fi
}

arch_package_name() {
    case "$1" in
        openssh) echo openssh ;;
        *) echo "$1" ;;
    esac
}

debian_package_name() {
    case "$1" in
        fd) echo fd-find ;;
        openssh) echo openssh-client ;;
        *) echo "$1" ;;
    esac
}

installed_pacman_package() {
    pacman -Q "$1" >/dev/null 2>&1
}

installed_debian_package() {
    dpkg-query -W -f='${db:Status-Abbrev}' "$1" 2>/dev/null | grep -q '^ii '
}

install_pacman_packages() {
    local missing=()
    local pkg

    for pkg in "$@"; do
        if ! installed_pacman_package "$pkg"; then
            missing+=("$pkg")
        fi
    done

    if ((${#missing[@]})); then
        sudo_cmd pacman -S --needed "${missing[@]}"
    fi
}

install_debian_packages() {
    local missing=()
    local unavailable=()
    local pkg

    for pkg in "$@"; do
        if ! apt-cache show "$pkg" >/dev/null 2>&1; then
            unavailable+=("$pkg")
            continue
        fi

        if ! installed_debian_package "$pkg"; then
            missing+=("$pkg")
        fi
    done

    if ((${#missing[@]})); then
        sudo_cmd apt-get update
        sudo_cmd apt-get install -y "${missing[@]}"
    fi

    if ((${#unavailable[@]})); then
        echo "Unavailable from configured apt repositories: ${unavailable[*]}" >&2
    fi
}

install_paru() {
    if command -v paru >/dev/null 2>&1; then
        return 0
    fi

    if ((DRY_RUN)); then
        echo "DRY-RUN: install paru from AUR"
        return 0
    fi

    local build_dir=/tmp/paru
    if [[ -d "$build_dir/.git" ]]; then
        git -C "$build_dir" pull --ff-only
    else
        rm -rf "$build_dir"
        git clone https://aur.archlinux.org/paru.git "$build_dir"
    fi
    (cd "$build_dir" && makepkg -si --noconfirm)
}

install_aur_packages() {
    local missing=()
    local pkg

    install_paru

    for pkg in "$@"; do
        if ! installed_pacman_package "$pkg"; then
            missing+=("$pkg")
        fi
    done

    if ((${#missing[@]})); then
        run_cmd paru -S --needed "${missing[@]}"
    fi
}

ensure_pnpm() {
    if command -v pnpm >/dev/null 2>&1; then
        return 0
    fi

    if [[ -f /etc/arch-release ]]; then
        install_pacman_packages pnpm
        return 0
    fi

    if [[ -f /etc/debian_version ]]; then
        install_debian_packages nodejs npm
        run_cmd npm install -g pnpm
        return 0
    fi

    echo "pnpm is not installed and no installer is configured for this distro." >&2
}

ensure_node_cli_tools() {
    if ! command -v npm >/dev/null 2>&1; then
        echo "npm is not installed; cannot install Node-based CLI tools." >&2
        return 1
    fi

    run_cmd npm install -g pnpm "tree-sitter-cli@$TREE_SITTER_CLI_VERSION"
}

neovim_release_arch() {
    case "$(uname -m)" in
        x86_64|amd64) echo x86_64 ;;
        aarch64|arm64) echo arm64 ;;
        *)
            echo "Unsupported Neovim release architecture: $(uname -m)" >&2
            return 1
            ;;
    esac
}

install_neovim_latest() {
    local arch
    local archive
    local install_dir
    local tmpdir
    local url

    if [[ "$(uname -s)" != Linux ]]; then
        echo "Skipping upstream Neovim install on non-Linux system: $(uname -s)"
        return 0
    fi

    arch="$(neovim_release_arch)"
    archive="nvim-linux-$arch.tar.gz"
    install_dir="/opt/nvim-linux-$arch"
    tmpdir="/tmp/neovim-install-$arch"
    url="https://github.com/neovim/neovim/releases/latest/download/$archive"

    if ((DRY_RUN)); then
        echo "DRY-RUN: install latest Neovim from $url to $install_dir and link /opt/nvim"
        return 0
    fi

    rm -rf "$tmpdir"
    mkdir -p "$tmpdir"
    curl -fL "$url" -o "$tmpdir/$archive"
    tar -C "$tmpdir" -xzf "$tmpdir/$archive"
    sudo_cmd rm -rf "$install_dir"
    sudo_cmd mv "$tmpdir/nvim-linux-$arch" "$install_dir"
    sudo_cmd ln -sfn "$install_dir" /opt/nvim
    rm -rf "$tmpdir"
}

bootstrap_packages() {
    local mapped=()
    local pkg

    if [[ -f /etc/arch-release ]]; then
        for pkg in "${SHARED_PACKAGES[@]}"; do
            mapped+=("$(arch_package_name "$pkg")")
        done
        install_pacman_packages "${mapped[@]}"

        if [[ "$HOST" == *desktop* ]]; then
            install_pacman_packages "${ARCH_DESKTOP_PACKAGES[@]}"
            install_aur_packages "${ARCH_DESKTOP_AUR_PACKAGES[@]}"
        fi
    elif [[ -f /etc/debian_version ]]; then
        for pkg in "${SHARED_PACKAGES[@]}"; do
            mapped+=("$(debian_package_name "$pkg")")
        done
        install_debian_packages "${mapped[@]}"
    else
        echo "No package bootstrap configured for this distro; skipping package install."
    fi
}

ensure_fish_shell() {
    local target_user="${SUDO_USER:-$USER}"
    local current_shell
    local fish_path

    if [[ "$target_user" == root ]]; then
        echo "Skipping fish shell change for root."
        return 0
    fi

    if ! fish_path="$(command -v fish 2>/dev/null)"; then
        echo "fish is not on PATH after package bootstrap." >&2
        return 1
    fi

    if ! grep -Fxq "$fish_path" /etc/shells; then
        if ((DRY_RUN)); then
            echo "DRY-RUN: add $fish_path to /etc/shells"
        else
            printf '%s\n' "$fish_path" | sudo tee -a /etc/shells >/dev/null
        fi
    fi

    current_shell="$(getent passwd "$target_user" | cut -d: -f7)"
    if [[ "$current_shell" != "$fish_path" ]]; then
        sudo_cmd chsh -s "$fish_path" "$target_user"
    fi
}

ensure_nvim() {
    if [[ -f /etc/arch-release ]]; then
        install_pacman_packages neovim
        if [[ -d /opt/nvim ]]; then
            sudo_cmd rm -rf /opt/nvim
        fi
    else
        install_neovim_latest
    fi
}

if ((BOOTSTRAP)); then
    bootstrap_packages
    ensure_nvim
    ensure_pnpm
    ensure_node_cli_tools
    ensure_fish_shell
fi

if ! command -v stow >/dev/null 2>&1; then
    echo "GNU Stow is not installed. Re-run without --no-bootstrap, or install stow manually." >&2
    exit 127
fi

cd "$DOTFILES_DIR"

PACKAGES=()
if ((${#REQUESTED_PACKAGES[@]})); then
    PACKAGES=("${REQUESTED_PACKAGES[@]}")
elif ((SYSTEM)); then
    if [[ -f /etc/arch-release && "$HOST" == "arch-desktop" && -d arch-desktop-system ]]; then
        PACKAGES=("arch-desktop-system")
    else
        echo "No system package selected for host: $HOST" >&2
        exit 1
    fi
else
    PACKAGES=("shared")

    if [[ "$HOST" == "arch-desktop" ]]; then
        if [[ -d arch-desktop ]]; then
            PACKAGES+=("arch-desktop")
        fi
    elif [[ "$HOST" == "vps" && -d vps ]]; then
        PACKAGES+=("vps")
    fi
fi

STOW_ARGS=(--dir "$DOTFILES_DIR" --target "$TARGET_DIR")
if ((RESTOW)); then
    STOW_ARGS+=(--restow)
fi
if ((DRY_RUN)); then
    STOW_ARGS+=(--no --verbose)
fi

BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%d_%H%M%S)"

echo "Host: $HOST"
echo "Target: $TARGET_DIR"
echo "Packages: ${PACKAGES[*]}"
if ((SYSTEM)) && [[ $EUID -ne 0 ]]; then
    echo "System packages target / and usually require root. Re-run with sudo if stow reports permission errors."
fi

for pkg in "${PACKAGES[@]}"; do
    if [[ ! -d "$pkg" ]]; then
        echo "Skip missing package: $pkg"
        continue
    fi

    echo
    echo "Checking package: $pkg"
    stow_check_output="$(stow --no --verbose --dir "$DOTFILES_DIR" --target "$TARGET_DIR" "$pkg" 2>&1)" || stow_check_status=$?
    stow_check_status="${stow_check_status:-0}"

    if ((DRY_RUN)); then
        printf '%s\n' "$stow_check_output"
    fi

    if ((stow_check_status != 0)); then
        if ((DRY_RUN)); then
            echo "Conflicts found for $pkg. Merge or back up these files before applying."
            continue
        fi

        if ((!BACKUP || DRY_RUN)); then
            echo "Conflicts found for $pkg. Re-run without --dry-run to back them up, or merge first." >&2
            exit 1
        fi

        mapfile -t conflicts < <(
            printf '%s\n' "$stow_check_output" |
                sed -n \
                    -e 's/.*existing target is neither a link nor a directory: //p' \
                    -e 's/.* over existing target \(.*\) since neither a link nor a directory.*/\1/p'
        )

        if ((${#conflicts[@]} == 0)); then
            printf '%s\n' "$stow_check_output" >&2
            echo "Stow reported a conflict, but it could not be parsed. Re-run with --dry-run and inspect manually." >&2
            exit 1
        fi

        for relpath in "${conflicts[@]}"; do
            src="$TARGET_DIR/$relpath"
            dst="$BACKUP_DIR/$relpath"
            if [[ -e "$src" && ! -L "$src" ]]; then
                echo "Backing up: $relpath"
                mkdir -p "$(dirname "$dst")"
                mv "$src" "$dst"
            fi
        done
    fi
    unset stow_check_status

    if ((DRY_RUN)); then
        stow "${STOW_ARGS[@]}" "$pkg"
    else
        stow "${STOW_ARGS[@]}" "$pkg"
    fi
done

echo
echo "Sync complete."
if [[ -d "$BACKUP_DIR" ]]; then
    echo "Backups: $BACKUP_DIR"
fi
