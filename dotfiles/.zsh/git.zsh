# note mporter:
# the oh-my-zsh git prompt is full of compromises..
# so here is my fork of it..

function git_prompt() {
    local ref
    ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
    echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(git_tracking_status)$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

function git_tracking_status() {
    local remote ahead behind STATUS
    STATUS=""
    remote=${$(command git rev-parse --verify ${hook_com[branch]}@{upstream} --symbolic-full-name 2>/dev/null)/refs\/remotes\/}

    if [[ -n ${remote} ]]; then
        ahead=$(command git rev-list ${hook_com[branch]}@{upstream}..HEAD 2> /dev/null | wc -l)
        behind=$(command git rev-list HEAD..${hook_com[branch]}@{upstream} 2> /dev/null | wc -l)

        if [[ $ahead -eq 0 ]] && [[ $behind -eq 0 ]]; then
            STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_EQUAL_PREFIX"
        fi
        if [[ $ahead -gt 0 ]]; then
            STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_AHEAD_PREFIX$((ahead))"
        fi
        if [[ $behind -gt 0 ]]; then
            STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_BEHIND_PREFIX$((behind))"
        fi

        STATUS="$STATUS$(git_index_status)"
        echo $STATUS
    fi
}

function git_index_status() {
    local added modified renamed deleted untracked unmerged INDEX STATUS
    INDEX=$(command git status --porcelain -b 2> /dev/null)
    STATUS=""
    added=$(command echo "$INDEX" | grep '^ A ' &> /dev/null | wc -l)
    modified=$(command echo "$INDEX" | grep '^ M ' &> /dev/null | wc -l)
    renamed=$(command echo "$INDEX" | grep '^ R ' &> /dev/null | wc -l)
    deleted=$(command echo "$INDEX" | grep '^ D ' &> /dev/null | wc -l)
    untracked=$(command echo "$INDEX" | grep '^\?\? ' &> /dev/null | wc -l)
    unmerged=$(command echo "$INDEX" | grep '^UU ' &> /dev/null | wc -l)

    if [[ $added -gt 0 ]]; then
        STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_ADDED_PREFIX$((added))"
    fi
    if [[ $modified -gt 0 ]]; then
        STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_MODIFIED_PREFIX$((modified))"
    fi
    if [[ $deleted -gt 0 ]]; then
        STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_DELETED_PREFIX$((deleted))"
    fi

    # bonus over posh-git
    if [[ $renamed -gt 0 ]]; then
        STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_RENAMED_PREFIX$((renamed))"
    fi

    # posh-git does not display these counts, so doing the same
    if [[ $untracked -gt 0 ]]; then
        STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED_PREFIX"
    elif [[ $unmerged -gt 0 ]]; then
        STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNMERGED_PREFIX"
    fi
    echo $STATUS
}