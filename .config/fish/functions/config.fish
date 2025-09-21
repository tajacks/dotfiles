function config --wraps='/opt/homebrew/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME' --description 'alias config=/opt/homebrew/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
  /opt/homebrew/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $argv
        
end
