# ~/.zprofile

# 如果有 .zshrc 就載入
[[ -f ~/.zshrc ]] && . ~/.zshrc

# 登入時直接啟動 Hyprland
exec Hyprland

