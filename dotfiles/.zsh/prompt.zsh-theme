# need a unicode compatible font and console
# Consolas is nice on Windows
# DejaVu is nice on Linux
# Hack is better on both

# custom git_prompt
ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg_bold[blue]%}[%{$fg_bold[blue]%}"

ZSH_THEME_GIT_PROMPT_EQUAL_PREFIX=" %{$fg[blue]%}%{≡%G%}"
ZSH_THEME_GIT_PROMPT_AHEAD_PREFIX=" %{$fg[yellow]%}%{↑%G%}"
ZSH_THEME_GIT_PROMPT_BEHIND_PREFIX=" %{$fg[yellow]%}%{↓%G%}"

ZSH_THEME_GIT_PROMPT_ADDED_PREFIX=" %{$fg[red]%}%{+%G%}"
ZSH_THEME_GIT_PROMPT_MODIFIED_PREFIX=" %{$fg[red]%}%{~%G%}"
ZSH_THEME_GIT_PROMPT_DELETED_PREFIX=" %{$fg[red]%}%{-%G%}"

ZSH_THEME_GIT_PROMPT_RENAMED_PREFIX=" %{$fg[red]%}%{±%G%}"
# ZSH_THEME_GIT_PROMPT_CONFLICTED_PREFIX=" %{$fg[red]%}%{!%G%}"

ZSH_THEME_GIT_PROMPT_UNTRACKED_PREFIX=" %{$fg[red]%}%{!%G%}"
ZSH_THEME_GIT_PROMPT_UNMERGED_PREFIX=" %{$fg[red]%}%{~%G%}"

ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg_bold[blue]%}]%{$reset_color%}"

OSID=$(cat /etc/os-release | awk -F= '/^ID=/{print $2}')

function charHost {
    if [[ $OSID == 'alpine' ]]; then echo '\uf300'
    elif [[ $OSID == 'arch' ]]; then echo '\uf303'
    elif [[ $OSID == 'manjaro' ]]; then echo '\uf312'
    elif [[ $OSID == 'debian' ]]; then echo '\uf306'
    elif [[ $OSID == 'raspbian' ]]; then echo '\uf315'
    elif [[ $OSID == 'ubuntu' ]]; then echo '\uf31b'
    elif [[ $OSID == 'linuxmint' ]]; then echo '\uf30e'
    elif [[ $OSID == 'rhel' ]]; then echo '\uf316'
    elif [[ $OSID == 'centos' ]]; then echo '\uf304'
    elif [[ $OSID == 'fedora' ]]; then echo '\uf30a'
    else echo '\uf17c'
    fi
}
function charUser {
    if [[ $USER == 'root' ]] ||
       [[ $USER == 'admin' ]]
    then echo '\uf0f0'
    elif [[ $USER == 'marshall' ]] ||
         [[ $USER == 'meop' ]] ||
         [[ $USER == 'meoporter' ]] ||
         [[ $USER == 'mporter' ]]
    then echo '\uf007'
    else echo '\uf21b'
    fi
}
function charFolder {
    echo '\uf07c'
}
function charPrompt {
    echo '\uf061'
}
function charShell {
    echo '\uf1d0'
}

# single quotes matters.. it prevents shell
# from evaluating the params at time of dot sourcing

# for zsh, $'' also forces evaluation of escape sequences

# custom prompt
ZSH_COLOR_CYAN=$'%{\e[36m%}'
ZSH_COLOR_MAGENTA=$'%{\e[35m%}'
ZSH_COLOR_WHITE=$'%{\e[37m%}'
ZSH_COLOR_YELLOW=$'%{\e[33m%}'

ZSH_COLOR_BLUE=$'%{\e[34m%}'

ZSH_COLOR_RESET=$'%{\e[0m%}'

ZSH_STATUS_INFO="${ZSH_COLOR_CYAN}$(charHost) %m ${ZSH_COLOR_MAGENTA}$(charUser) %n ${ZSH_COLOR_WHITE}$(charShell) zsh ${ZSH_COLOR_YELLOW}$(charFolder) %d${ZSH_COLOR_RESET}"
ZSH_STATUS_CMD="${ZSH_COLOR_BLUE}$(charPrompt) ${ZSH_COLOR_RESET}"
ZSH_NEWLINE=$'\n'

PROMPT=$' ${ZSH_STATUS_INFO}% $(git_prompt)${ZSH_NEWLINE} ${ZSH_STATUS_CMD}'
