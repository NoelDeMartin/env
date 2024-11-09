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
alias grs="git reset HEAD~1 --soft"
alias gc="git checkout"
alias gca="git commit --amend"
alias gpu="git push"
alias gpuf="git push --force-with-lease"
alias gwip="git add . && git commit -m 'wip'"

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
alias nclear="find ./ -type d -name '.cache' -exec rm -rf {} +"

function nrefresh() {
    # Clean up lock files and installed dependencies
    rm package-lock.json
    find ./ -type d -name "node_modules" -exec rm -rf {} +

    # Reinstall dependencies
    npm install
}

function nreset() {
    # Clean up installed dependencies
    find ./ -type d -name "node_modules" -exec rm -rf {} +

    # Reinstall dependencies
    npm ci
}

# Metal
alias mu="metal up --only"
alias md="metal down"
alias mr="metal restart"

# Laravel
alias sail="[ -f sail ] && bash sail || bash vendor/bin/sail"
alias su="sail up -d"
alias sd="sail down"
alias art="sail artisan"
alias at="art test"
alias composer="docker run --rm -u '$(id -u):$(id -g)' -v '$(pwd):/var/www/html' -w /var/www/html laravelsail/php82-composer:latest composer"
