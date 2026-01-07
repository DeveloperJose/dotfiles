function chadd --description 'chezmoi re-add, stage all, commit, and push'
    # 1. Sync current state to source directory
    chezmoi re-add
    
    set -l chezmoi_dir (chezmoi source-path)
    set -l commit_msg $argv

    # 2. If no message passed, show status and prompt
    if test (count $argv) -eq 0
        echo (set_color yellow)"--- Current Chezmoi Status ---"(set_color normal)
        git -C $chezmoi_dir status -s
        echo "------------------------------"
        
        read -P "Enter commit message: " commit_msg
        
        if test -z "$commit_msg"
            echo (set_color red)"Abort: No commit message provided."(set_color normal)
            return 1
        end
    end

    # 3. Stage, Commit, and Push
    git -C $chezmoi_dir add -A
    
    if git -C $chezmoi_dir commit -m "$commit_msg"
        echo (set_color green)"Pushing changes to remote..."(set_color normal)
        git -C $chezmoi_dir push
    else
        echo (set_color yellow)"Nothing to commit, skipping push."(set_color normal)
    end
end
