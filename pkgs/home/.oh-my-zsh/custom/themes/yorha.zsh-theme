# oh-my-zsh theme (truecolor) — surrealism 分支:Magritte night 配色
# (檔名沿用 yorha 給 ZSH_THEME 參照;此分支內容已改成 surrealism 色。)
# 提亮確保在深夜色終端底 (#141c28, 0.85 半透) 上清楚可讀。
# sky #7fb0d8 / cloud #b9c4d0 / lamp #e6b24e / apple #7ba46f / 赭紅 #cc7f74 / stone #8b97a5

# Git 分支(簡潔)
function _yorha_git {
  (( $+commands[git] )) || return
  local br
  br=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null) || return
  print -n "%F{#6f9fca}%f %F{#cc7f74}${br}%f "
}

# 右提示:時間
RPROMPT='%F{#8b97a5}%*%f'

# 左提示:使用者@主機 / 目錄 / git / 提示符(%# 用 lamp 金當唯一暖色 accent)
PROMPT='%F{#7fb0d8}%n%f@%F{#7fb0d8}%m%f %F{#b9c4d0}%~%f $(_yorha_git)%F{#e6b24e}%#%f '
