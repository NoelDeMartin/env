# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ll="ls -la"

function go() {
    cd "/home/`whoami`/workspace/$1"
}

function goAutocomplete() {
    local file

    for file in /home/`whoami`/workspace/"$2"*; do
        [[ -d $file ]] || continue

        COMPREPLY+=( $(basename "$file") )
    done
}

complete -F goAutocomplete go

# Permissions
alias own="sudo chown `whoami`:`whoami` . -R"

# Git
alias gs="git status"
alias gp="git pull"
alias gl="git log --oneline"
alias gr="git rebase"
alias grc="git rebase --continue"
alias gra="git rebase --abort"
alias gc="git checkout"
alias gca="git commit --amend"
alias gpu="git push"
alias gpuf="git push --force-with-lease"

function gri() {
    git rebase -i HEAD~$1
}

if [ -f "/usr/share/bash-completion/completions/git" ]; then
    source /usr/share/bash-completion/completions/git

    __git_complete gc _git_checkout
    __git_complete gr _git_rebase
    __git_complete gpu _git_push
    __git_complete gpuf _git_push
fi

# Npm
alias ni="npm install --save-dev"
alias nii="npm install --save"
alias nu="npm uninstall"
alias nd="npm run dev"
alias nt="npm run test"
alias ns="npm run serve"
alias nr="npm run"

# Metal
alias mu="metal up --only"
alias md="metal down"
alias mr="metal restart"
