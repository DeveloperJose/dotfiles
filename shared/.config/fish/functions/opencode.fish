function opencode
    # Path to the dev repo
    set -l repo_root ~/local-arch/ai/opencode/packages/opencode
    set -x OPEN_CODE_EXPERIMENTAL true

    # Run the dev CLI, forward current project dir + all user args
    # Append default flags at the end
    bun run --cwd $repo_root dev $argv -- $PWD
end
