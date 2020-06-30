if ( ($IsWindows -and -not (Test-Path "$env:HOME/vimfiles/autoload/plug.vim")) -or
    (-not (Test-Path "$env:HOME/.vim/autoload.plug.vim"))
) {
    $uri = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

    if ($IsWindows) {
        mkdir "$env:HOME/vimfiles/autoload"
        (New-Object Net.WebClient).DownloadFile(
            $uri,
            $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
                "$env:HOME/vimfiles/autoload/plug.vim"
            )
        )
    } else {
        curl -fLo "$env:HOME/.vim/autoload/plug.vim" --create-dirs $uri
    }
}

if (-not $IsWindows -and -not (Test-Path "$env:HOME/.tmux/plugins/tpm")) {
    git clone 'https://github.com/tmux-plugins/tpm' "$env:HOME/.tmux/plugins/tpm"
} else {
    Push-Location "$env:HOME/.tmux/plugins/tpm"
    git pull
    Pop-Location
}

if (-not $IsWindows -and -not (Test-Path "$env:HOME/.zplug")) {
    git clone 'https://github.com/zplug/zplug' "$env:HOME/.zplug"
} else {
    Push-Location "$env:HOME/.zplug"
    git pull
    Pop-Location
}