# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ll="ls -la"

function go() {
    # TODO implement autocompletion

    cd "/home/`whoami`/workspace/$1"
}

# Permissions
alias own="sudo chown `whoami`:`whoami` . -R"

# Git
alias gs="git status"
alias gp="git pull"
alias gl="git log --oneline"

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
