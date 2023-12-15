# VSCode opens terminals in the project root, so this will make sure that
# you're using the correct version of npm and node
currentdir=`pwd`

while [ $currentdir != "/" ] && [ ! -f "$currentdir/.nvmrc" ]; do
    currentdir=`dirname $currentdir`
done

if [ $currentdir != "/" ]; then
    nvm install &> /dev/null
fi

# Change default prompt
PROMPT_COMMAND=__prompt_command

__prompt_command() {
    local exitcode=$?
    local command=`history | tail -1 | cut -c 8-`

    if [[ $exitcode == 0 ]] || \

        # 130 - Ignore manual interruption
        [[ $exitcode == 130 ]] || \

        # 141 - Ignore exiting `git log` command (aliased as "gl")
        [[ $exitcode == 141 && $command == "gl" ]]
    then
        PS1="🤖 "
    else
        PS1="💥 "
    fi
}

# Configure custom scripts
export PATH=[projects-path]/env/bin:$PATH
