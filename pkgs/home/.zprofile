# ~/.zprofile

# 如果有 .zshrc 就載入
[[ -f ~/.zshrc ]] && . ~/.zshrc

if [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]]; then
    exec Hyprland > /dev/null 2>&1 < /dev/null
fi
