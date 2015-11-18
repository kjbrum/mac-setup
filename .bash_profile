#---------------------------------------------------------------------------------------------------------------------------------------
#
#   Author: Kyle Brumm
#
#   Description: File used to hold Bash configuration, aliases, functions, completions, etc...
#
#   Sections:
#   1.  ENVIRONMENT SETUP
#   2.  MAKE TERMINAL BETTER
#   3.  FOLDER MANAGEMENT
#   4.  MISC ALIAS'
#   5.  GIT SHORTCUTS
#   6.  OS X COMMANDS
#   7.  TAB COMPLETION
#
#---------------------------------------------------------------------------------------------------------------------------------------


#---------------------------------------------------------------------------------------------------------------------------------------
#   1.  ENVIRONMENT SETUP
#---------------------------------------------------------------------------------------------------------------------------------------

# Set colors to variables
BLACK="\[\033[0;30m\]"
BLACKB="\[\033[1;30m\]"
RED="\[\033[0;31m\]"
REDB="\[\033[1;31m\]"
GREEN="\[\033[0;32m\]"
GREENB="\[\033[1;32m\]"
YELLOW="\[\033[0;33m\]"
YELLOWB="\[\033[1;33m\]"
BLUE="\[\033[0;34m\]"
BLUEB="\[\033[1;34m\]"
PURPLE="\[\033[0;35m\]"
PURPLEB="\[\033[1;35m\]"
CYAN="\[\033[0;36m\]"
CYANB="\[\033[1;36m\]"
WHITE="\[\033[0;37m\]"
WHITEB="\[\033[1;37m\]"

# Get Git branch of current directory
git_branch () {
    if git rev-parse --git-dir >/dev/null 2>&1
        then echo -e "" git:\($(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')\)
    else
        echo ""
    fi
}

# Set a specific color for the status of the Git repo
git_color() {
    local STATUS=`git status 2>&1`
    if [[ "$STATUS" == *'Not a git repository'* ]]
        then echo "" # nothing
    else
        if [[ "$STATUS" != *'working directory clean'* ]]
            then echo -e '\033[0;31m' # red if need to commit
        else
            if [[ "$STATUS" == *'Your branch is ahead'* ]]
                then echo -e '\033[0;33m' # yellow if need to push
            else
                echo -e '\033[0;32m' # else green
            fi
        fi
    fi
}

# Check if perl is installed
repo_file="$HOME/bin/bitbucket-repos.txt"
if which perl > /dev/null; then
    if [ ! -f $repo_file ]; then
        next_run=0
        touch $repo_file
    else
        interval='6' # How often we should check for new repos (hours)
        last_run=$(perl -MPOSIX -e 'print POSIX::strftime "%Y%m%d%H\n", localtime((stat $ARGV[0])[9])' $repo_file)
        next_run=$((last_run+interval))
    fi

    current=$(date +%Y%m%d%H)

    # Check if we should update the bitbucket-repo.txt
    if [ "$next_run" -le "$current" ]; then
        echo -n 'Updating bitbucket repos'
        rm $repo_file
        php $HOME/bin/bitbucket-repos > $repo_file &
        pid=$!
        while kill -0 $pid &> /dev/null; do
            echo -n "."
            sleep 0.5
        done
        echo -e "\n"
    fi
else
    rm $repo_file
    php $HOME/bin/bitbucket-repos > $repo_file &
    pid=$!
    while kill -0 $pid &> /dev/null; do
        echo -n "."
        sleep 0.5
    done
    echo -e "\n"
fi


# Add ssh keys if needed
if [ ! $(ssh-add -l | grep -o -e id_rsa) ]; then
    ssh-add "$HOME/.ssh/id_rsa" > /dev/null 2>&1
fi

# Modify the prompt
# Symbols: http://panmental.de/symbols/info.htm
date
export PS1=$BLUE'\u'$PURPLE' at '$BLUE'\h'$PURPLE' → '$BLACK'\e[46m[\w]\e[0m$(git_color)$(git_branch)\n'$BLUE'\$ '
# export PS1=$BLUE'\u'$PURPLE' at '$BLUE'\h'$PURPLE' → '$BLACK'\e[46m[\w]\e $(git-radar --bash --fetch)\n'$BLUE'\$ '

# Set tab name to the current directory
export PROMPT_COMMAND='echo -ne "\033]0;${PWD##*/}\007"'

# Add color to terminal
export CLICOLOR=1
export LSCOLORS=GxExBxBxFxegedabagacad

# Setup our $PATH
export PATH=/usr/local/bin:/usr/local/sbin:$HOME/.go/bin:/usr/local/mysql/bin:$HOME/bin:$PATH

# Add Github script projects
for i in $(ls -d $HOME/scripts/*); do
    PATH=$PATH:$i
done

# Setup RBENV stuff
export RBENV_ROOT=/usr/local/var/rbenv

# Setup NVM stuff
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh

# Set our Homebrew Cask application directory
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
[[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh

# Other Stuff
source $(brew --prefix grc)/etc/grc.bashrc
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# Tell NPM to compile and install all your native addons in parallel and not sequentially
export JOBS=max

# Bump the maximum number of file descriptors you can have open
ulimit -n 10240

# thefuck settings
export THEFUCK_REQUIRE_CONFIRMATION='true'


#---------------------------------------------------------------------------------------------------------------------------------------
#   2.  MAKE TERMINAL BETTER
#---------------------------------------------------------------------------------------------------------------------------------------

# Bundle shortcuts
alias bec='bundle exec cap'
alias becs='bundle exec cap staging'
alias becp='bundle exec cap production'

happystaging() {
    while true; do
        read -ep 'Pull or push STAGING site? [pull/push] ' response
        case $response in
            pull )
                while true; do
                    read -ep 'Are you sure you want to PULL changes from STAGING? [Y/n] ' yesno
                    case $yesno in
                        [Nn]* )
                            break;;
                        * )
                            bash -c 'bundle exec cap staging db:pull && bundle exec cap staging uploads:sync'
                            break;;
                    esac
                done
                break;;
            push )
                while true; do
                    read -ep 'Are you sure you want to PUSH changes to STAGING? [Y/n] ' yesno
                    case $yesno in
                        [Nn]* )
                            break;;
                        * )
                            bash -c 'bundle exec cap staging deploy && bundle exec cap staging db:push && bundle exec cap staging uploads:sync'
                            break;;
                    esac
                done
                break;;
        esac
    done
}

happyproduction() {
    while true; do
        read -ep 'Pull or push PRODUCTION site? [pull/push] ' response
        case $response in
            pull )
                while true; do
                    read -ep 'Are you sure you want to PULL changes from PRODUCTION? [Y/n] ' yesno
                    case $yesno in
                        [Nn]* )
                            break;;
                        * )
                            bash -c 'bundle exec cap production db:pull && bundle exec cap production uploads:sync'
                            break;;
                    esac
                done
                break;;
            push )
                while true; do
                    read -ep 'Are you sure you want to PUSH changes to PRODUCTION? [Y/n] ' yesno
                    case $yesno in
                        [Nn]* )
                            break;;
                        * )
                            bash -c 'bundle exec cap production deploy && bundle exec cap production db:push && bundle exec cap production uploads:sync'
                            break;;
                    esac
                done
                break;;
        esac
    done
}

# Misc Commands
alias resource='source ~/.bash_profile'                                         # Source bash_profile
bash-as() { sudo -u $1 /bin/bash; }                                             # Run a bash shell as another user
alias getsshkey='pbcopy < ~/.ssh/id_rsa.pub'                                    # Copy ssh key to the keyboard
alias ll='ls -alh'                                                              # List files
alias llr='ls -alhr'                                                            # List files (reverse)
alias lls='ls -alhS'                                                            # List files by size
alias llsr='ls -alhSr'                                                          # List files by size (reverse)
alias lld='ls -alht'                                                            # List files by date
alias lldr='ls -alhtr'                                                          # List files by date (reverse)
alias h="history"                                                               # Shorthand for `history` command
alias perm="stat -f '%Lp'"                                                      # View the permissions of a file/dir as a number
alias mkdir='mkdir -pv'                                                         # Make parent directories if needed
alias fuck='eval $(thefuck $(fc -ln -1)); history -r'                           # Alias for running thefuck
alias mysql.server='sudo /usr/local/mysql/support-files/mysql.server'

# Editing common files
alias editbash='subl ~/.bash_profile'                                           # Edit bash profile
alias editsharedbash='subl ~/Dropbox/Preferences/.shared_bash_profile'          # Edit shared bash profile in Dropbox
alias edithosts='subl /etc/hosts'                                               # Edit hosts file
alias editsshhosts='subl ~/.ssh/config'                                         # Edit the ssh config file

# Navigation Shortcuts
alias ..='cl ..'
alias ...='cl ../../'
alias ....='cl ../../../'
alias .....='cl ../../../../'
alias ......='cl ../../../../'
alias .......='cl ../../../../../'
alias ........='cl ../../../../../../'
alias home='clear && cd && ll'                                                  # Home directory
cs() { cd "$@" &&  ls; }                                                        # Enter directory and list contents with ls
cl() { cd "$@" && ll; }                                                         # Enter directory and list contents with ll
project() { clear && cl /www/sites/"$@"; }                                      # Access project folders easier
theme() { clear && cl /www/sites/"$@"/content/themes/"$@"; }                    # Access theme folders easier


#---------------------------------------------------------------------------------------------------------------------------------------
#   3.  FOLDER MANAGEMENT
#---------------------------------------------------------------------------------------------------------------------------------------

# Clear a directory
cleardir() {
    while true; do
        read -ep 'Completely clear current directory? [y/N] ' response
        case $response in
            [Yy]* )
                bash -c 'rm -rfv ./*'
                bash -c 'rm -rfv ./.*'
                break;;
            * )
                echo 'Skipped clearing the directory...'
                break;;
        esac
    done
}

mktar() { tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; }    # Creates a *.tar.gz archive of a file or folder
mkzip() { zip -r "${1%%/}.zip" "$1" ; }               # Create a *.zip archive of a file or folder


#---------------------------------------------------------------------------------------------------------------------------------------
#   4.  MISC ALIAS'
#---------------------------------------------------------------------------------------------------------------------------------------

# Stuff to make wp-install.sh work correctly
# http://stackoverflow.com/questions/19242275/re-error-illegal-byte-sequence-on-mac-os-x
export LC_CTYPE=C
export LANG=C

# browser-sync
alias bs='browser-sync'    # Browser Sync shorthand
bsdev() { browser-sync start --files "**/style.css, **/global.min.js, **/init.js, **/*.php, **/*.html, **/*.mustache" --proxy "$@.dev" --port 3000 --tunnel "hmkyle"; }    # Start local project BS server

# Grunt
alias gw='grunt watch'    # Start the Grunt "watch" task
alias gbs='grunt bs'      # Start the Grunt "browser-sync" task

# Trash
alias t='trash'

# Ghost/Buster
alias gbuster="buster generate --domain=http://127.0.0.1:2368"
alias gbuster-replace="buster generate --domain=http://127.0.0.1:2368 && cd static && find ./ -type f -exec sed -i '' "s/localhost:2368/kylebrumm.com/" {} \;"

# Start a web server to share the files in the current directory
sharefolder() {
    myip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
    open http://$myip:5555
    python -m SimpleHTTPServer 5555
}

# Search with termflix
stream() { termflix search $@; }

# Send yourself a text
textme() {
    curl http://textbelt.com/text -d number=3199296351 -d message="$@"
}

# Open a local project in the browser
openproject() {
    # Add autocomplete for all projects (get list from bitbucket-repos.txt)
    # Check to see if we are opening a WP or PL
    # Add an option for opening the staging URL
    local OLD_IFS="$IFS"
    dir=$(pwd)
    set -- "$dir"

    IFS="/";
    declare -a project=($*)

    if [ "${project[2]}" == "sites" ]; then
        open http://${project[3]}.dev
    else
        echo "You aren't in a project directory..."
    fi

    IFS="$OLD_IFS"
}


#---------------------------------------------------------------------------------------------------------------------------------------
#   5.  GIT SHORTCUTS
#---------------------------------------------------------------------------------------------------------------------------------------

alias gitstats='git-stats'
alias gits='git status -s'
alias gita='git add -A && git status -s'
alias gitcom='git commit -am'
alias gitacom='git add -A && git commit -am'
alias gitc='git checkout'
alias gitcd='git checkout development'
alias gitcm='git checkout master'
alias gitb='git branch'
alias gitcb='git checkout -b'
alias gitdb='git branch -d'
alias gitDb='git branch -D'
alias gitf='git fetch'
alias gitr='git rebase'
alias gitp='git push -u'
alias gitpl='git pull'
alias gitfr='git fetch && git rebase'
alias gitfrp='git fetch && git rebase && git push -u'
alias gitpo='git push -u origin'
alias gitpom='git push -u origin master'
alias gitm='git merge'
alias gitmd='git merge development'
alias gitmm='git merge master'
alias gitcl='git clone'
alias gitclr='git clone --recursive'
alias gitamend='git commit --amend'
alias gitcundo='git reset --soft HEAD~1'
alias gitmpages='gitc gh-pages && gitm master && gitp && gitc master'
alias gitrao='git remote add origin'
alias gittrack='git update-index --no-assume-unchanged'
alias gituntrack='git update-index --assume-unchanged'
alias gitpullsubmodules='git submodule foreach git pull origin master'
alias gitremoveremote='git rm -r --cached'
alias gitlog="git log --graph --pretty=format:'%C(red)%h%C(reset) -%C(yellow)%d%C(reset) %s %C(green)(%cr) %C(blue)<%an>%C(reset)' --abbrev-commit"
alias gitlog-changes="git log --oneline --decorate --stat --graph --pretty=format:'%C(red)%h%C(reset) -%C(yellow)%d%C(reset) %s %C(green)(%cr) %C(blue)<%an>%C(reset)%n'"
gitupstream() { git branch --set-upstream-to="$@"; }
hmclone() {
    if [ -z "$@" ]; then
        echo 'You need to supply an argument...'
    else
        git clone --recursive git@bitbucket.org:itsahappymedium/"$@".git /www/sites/"$@"
        cl /www/sites/"$@"
    fi

}
gitreset() {
    while true; do
        read -ep 'Reset HEAD? [y/N] ' response
        case $response in
            [Yy]* )
                bash -c 'git reset --hard HEAD'
                break;;
            * )
                echo 'Skipped reseting the HEAD...'
                break;;
        esac
    done
}


#---------------------------------------------------------------------------------------------------------------------------------------
#   6.  OS X COMMANDS
#---------------------------------------------------------------------------------------------------------------------------------------

alias add-dock-spacer='defaults write com.apple.dock persistent-apps -array-add "{'tile-type'='spacer-tile';}" && killall Dock'   # Add a spacer to the dock
alias show-hidden-files='defaults write com.apple.finder AppleShowAllFiles 1 && killall Finder'                                   # Show hidden files in Finder
alias hide-hidden-files='defaults write com.apple.finder AppleShowAllFiles 0 && killall Finder'                                   # Hide hidden files in Finder
alias show-dashboard='defaults write com.apple.dashboard mcx-disabled -boolean NO && killall Dock'                                # Show the Dashboard
alias hide-dashboard='defaults write com.apple.dashboard mcx-disabled -boolean YES && killall Dock'                               # Hide the Dashboard
alias show-spotlight='sudo mdutil -a -i on'                                                                                       # Enable Spotlight
alias hide-spotlight='sudo mdutil -a -i off'                                                                                      # Disable Spotlight
alias today='grep -h -d skip `date +%m/%d` /usr/share/calendar/*'                                                                 # Get history facts about the day
alias mergepdf='/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py'                                  # Merge PDF files - Usage: `mergepdf -o output.pdf input{1,2,3}.pdf`


#---------------------------------------------------------------------------------------------------------------------------------------
#   7.  TAB COMPLETION
#---------------------------------------------------------------------------------------------------------------------------------------

# Add tab completion for NVM
[[ -r $NVM_DIR/bash_completion ]] && . $NVM_DIR/bash_completion

# Add tab completion for many Bash commands
if which brew > /dev/null && [ -f "$(brew --prefix)/share/bash-completion/bash_completion" ]; then
    source "$(brew --prefix)/share/bash-completion/bash_completion";
elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion;
fi;

# Add tab completion for vagrant commands
if [ -f `brew --prefix`/etc/bash_completion.d/vagrant ]; then
    source `brew --prefix`/etc/bash_completion.d/vagrant
fi

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal" killall;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Bash completion for the `project`, `theme` and `bsdev` aliases
_local_projects_complete() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    project_folder="/www/sites/"
    opts="$(ls $project_folder)"

    COMPREPLY=( $(compgen -W "$opts" -- $cur) )
}
complete -o nospace -F _local_projects_complete project
complete -o nospace -F _local_projects_complete theme
complete -o nospace -F _local_projects_complete bsdev

# Bash completion for the `hmclone` alias
_bitbucket_itsahappymedium_complete() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    opts=$(cat $HOME/bin/bitbucket-repos.txt)

    COMPREPLY=( $(compgen -W "$opts" -- $cur) )
}
complete -o nospace -F _bitbucket_itsahappymedium_complete hmclone

# Bash completion for the `wp` command (wp-cli)
_wp_complete() {
    local OLD_IFS="$IFS"
    local cur=${COMP_WORDS[COMP_CWORD]}

    IFS=$'\n';  # want to preserve spaces at the end
    local opts="$(wp cli completions --line="$COMP_LINE" --point="$COMP_POINT")"

    if [[ "$opts" =~ \<file\>\s* ]]
    then
        COMPREPLY=( $(compgen -f -- $cur) )
    elif [[ $opts = "" ]]
    then
        COMPREPLY=( $(compgen -f -- $cur) )
    else
        COMPREPLY=( ${opts[*]} )
    fi

    IFS="$OLD_IFS"
    return 0
}
complete -o nospace -F _wp_complete wp

# Bash completion for dvlp
_dvlp_complete() {
    COMPREPLY=()
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [ $COMP_CWORD -eq 1 ]; then
        COMPREPLY=( $(compgen -W 'cleanup init list start version' -- $cur) )
    elif [ $COMP_CWORD -eq 2 ]; then
        case "$prev" in
            start)
                project_folder="/www/sites/"
                opts="$(ls $project_folder)"
                COMPREPLY=( $(compgen -W "$opts" -- $cur) )
                ;;
        esac
    fi
}
complete -o nospace -F _dvlp_complete dvlp
