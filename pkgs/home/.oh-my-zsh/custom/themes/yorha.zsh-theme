# Yorha oh-my-zsh theme (truecolor) — retroism 淺色 yorha 配色
# 顏色都壓深，確保在淺暖終端底 (#baafa1) 上清楚可讀。
# olive #626335 / 路徑近黑 #2b2a26 / 磚紅 #9e3b2e / 板岩藍 #3d5a72 / 暖灰 #6b655a

# Git 分支（簡潔）
function _yorha_git {
  (( $+commands[git] )) || return
  local br
  br=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null) || return
  print -n "%F{#3d5a72}%f %F{#9e3b2e}${br}%f "
}

# 右提示：時間
RPROMPT='%F{#6b655a}%*%f'

# 左提示：使用者@主機 / 目錄 / git / 提示符
PROMPT='%F{#626335}%n%f@%F{#626335}%m%f %F{#2b2a26}%~%f $(_yorha_git)%F{#626335}%#%f '
