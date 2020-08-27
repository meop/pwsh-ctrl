. ~/.zplug/init.zsh

zplug 'zplug/zplug', hook-build:'zplug --self-manage'

zplug "rupa/z", as:plugin, use:z.sh

zplug "lib/directories", from:oh-my-zsh
zplug "lib/grep", from:oh-my-zsh
zplug "lib/history", from:oh-my-zsh
zplug "lib/key-bindings", from:oh-my-zsh

zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-history-substring-search", on:"zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# Modified from original version
zplug "~/.zsh", from:local
zplug "~/.zsh", from:local, as:theme, use:"prompt.zsh-theme", defer:2

# Install plugins if there are plugins that have not been installed
if ! zplug check; then
  zplug install
fi

# Then, source plugins and add commands to $PATH
zplug load


ZSH_THEME="prompt"

zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'


# AWS Tab Completion
autoload bashcompinit && bashcompinit
complete -C '/usr/local/bin/aws_completer' aws


# Setup basic shell tools

export VISUAL=vim


# Setup drivers

# Intel
export LIBVA_DRIVER_NAME="iHD"
# Nvidia
#export LIBVA_DRIVER_NAME="vdpau"


# X functions
function xDisplaySetUnix {
  export DISPLAY=:0
}

function xDisplayUnset {
  unset DISPLAY
}

function xHostSetLocal {
  xhost +local:
}

function xHostUnset {
  xhost -
}

function xRandRAmdgpu {
  xrandr --output HDMI-A-0 --mode 3840x1600 --rate 59.99 --pos 0x0 --primary --output DisplayPort-0 --mode 2560x1440 --rate 59.95 --pos 3840x160 --output DisplayPort-1 --off --output DisplayPort-2 --off --output HDMI2 --off --output HDMI3 --off --output DP4 --off
}

function kdeResetPanelShortcuts {
  rm ~/.config/kglobalshortcutsrc
  rm ~/.config/plasma-org.kde.plasma.desktop-appletsrc
}


# VNC functions
function x11vncctl {
  usage="usage: $0 {start|status|stop}"
  case $1 in
    start)
      x11vnc -display :0 -tightfilexfer -repeat -noxdamage -rfbauth ~/.vnc/passwd -nevershared -forever -bg
      ;;
    status)
      grep x11vnc =(ps aux)
      ;;
    stop)
      killall x11vnc
      ;;
    *)
      echo $usage
      ;;
  esac
}

function xvncctl {
  usage="usage: $0 {start|status|stop} {c|cinnamon|d|deepin|g|gnome|k|kde}"
  case $2 in
    c|cinnamon) display=4 ;;
    d|deepin) display=3 ;;
    g|gnome) display=2 ;;
    k|kde) display=1 ;;
    *) display=1 ;;
  esac
  if [[ $display -gt 0 ]]; then
    case $1 in
      start)
        export XVNC_DESKTOP_ENVIRONMENT=$2
        #vncserver :$display -geometry 3840x1600 -desktop $2 -rfbauth ~/.vnc/passwd -nevershared
        vncserver :$display -geometry 1920x1080 -desktop $2 -rfbauth ~/.vnc/passwd -nevershared
        ;;
      status)
        grep "Xvnc :$display" =(ps aux)
        ;;
      stop)
        vncserver -kill :$display
        ;;
      *)
        echo $usage
        ;;
    esac
  else
    echo $usage
  fi
}
