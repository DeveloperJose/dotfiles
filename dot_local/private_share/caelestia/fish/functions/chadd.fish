function chadd --description 'chezmoi re-add, stage all, and commit with message'
    # Check if a message was provided
    if test (count $argv) -eq 0
        echo "Error: Please provide a commit message."
        echo "Usage: chadd \"your message here\""
        return 1
    end

    # Run the sequence
    chezmoi re-add
    
    # Use chezmoi's source directory context to run git commands
    set -l chezmoi_dir (chezmoi source-path)
    
    git -C $chezmoi_dir add -A
    git -C $chezmoi_dir commit -m "$argv"
    git -C $chezmoi_dir push
    
    echo "Changes committed and pushed to chezmoi source: $argv"
end
