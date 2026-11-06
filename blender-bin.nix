# Upstream (builder.blender.org) Blender binary with CUDA/OptiX included.
# Mirrors https://github.com/edolstra/nix-warez proto-blender flake, non-flake style.
{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "blender-bin";
  version = "5.0.1";
  src = pkgs.fetchurl {
    url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender5.0/blender-5.0.1-linux-x64.tar.xz";
    hash = "sha256-gBlYDuG3Ji5QX0GWoAI3zPdDyI0gWzjTQgFRBnbmCwk=";
  };

  buildInputs = [ pkgs.makeWrapper ];

  libs = with pkgs; [
    wayland libdecor xorg.libX11 xorg.libXi
    (xorg.libxxf86vm or xorg.libXxf86vm)
    xorg.libXfixes xorg.libXrender libxkbcommon libGLU libglvnd numactl SDL2 libdrm ocl-icd stdenv.cc.cc.lib openal alsa-lib pulseaudio
  ] ++ pkgs.lib.optionals (pkgs.lib.versionAtLeast version "3.5") [
    xorg.libSM xorg.libICE zlib
  ] ++ pkgs.lib.optionals (pkgs.lib.versionAtLeast version "4.5") [
    vulkan-loader
  ];

  preUnpack = ''
    mkdir -p $out/libexec
    cd $out/libexec
  '';

  installPhase = ''
    cd $out/libexec
    mv blender-* blender

    mkdir -p $out/share/applications
    mkdir -p $out/share/icons/hicolor/scalable/apps
    mv ./blender/blender.desktop $out/share/applications/blender.desktop
    mv ./blender/blender.svg $out/share/icons/hicolor/scalable/apps/blender.svg

    mkdir $out/bin

    makeWrapper $out/libexec/blender/blender $out/bin/blender \
      --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib:${pkgs.lib.makeLibraryPath libs}

    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      blender/blender

    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      $out/libexec/blender/*/python/bin/python3*
  '';

  meta.mainProgram = "blender";
}
