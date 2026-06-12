# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="yorha"
plugins=(git z zsh-autosuggestions)


# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

unset SSH_AGENT_PID
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/ssh-agent.socket"

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
eval "$(dircolors ~/.dircolors)"
# ~/.zshrc（建議放在 compinit 之後）
autoload -Uz compinit
compinit
zmodload zsh/complist

# 讓補全清單用 LS_COLORS 的配色
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# 可視化選單
zstyle ':completion:*' menu select

# 保存你原本的 prompt
# retroism/yorha 調：壓深以配淺色終端底
typeset -g DAYBREAK_OK='#5e6e2f'
typeset -g DAYBREAK_ERR='#9e3b2e'
ORIGINAL_PROMPT=$PROMPT

autoload -Uz add-zsh-hook

show_status() {
  local exit_code=$?

  if [[ $exit_code -eq 0 ]]; then
    PROMPT="%F{$DAYBREAK_OK}0%f $ORIGINAL_PROMPT"
  else
    PROMPT="%F{$DAYBREAK_ERR}$exit_code%f $ORIGINAL_PROMPT"
  fi
}

add-zsh-hook precmd show_status

export PATH=~/.local/bin:$PATH

# Flutter
export PATH=$HOME/Downloads/flutter/bin:$PATH
export CHROME_EXECUTABLE=/usr/bin/chromium

# Android SDK
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/emulator"

xrdb -merge ~/.Xresources

#big delete
bindkey '^H' backward-kill-word

eval $(thefuck --alias)

command -v fastfetch >/dev/null 2>&1 && fastfetch

alias lg='lazygit'
alias nv='nvim'
unalias z
eval "$(zoxide init zsh)"
tw() {
  if [ -t 0 ]; then
    trans -brief :zh-TW "$*"
  else
    while read -r line; do
      trans -brief :zh-TW "$line"
    done
  fi
}
export PATH="$PATH":"$HOME/.pub-cache/bin"

# ── dotfiles 主題切換（git branch = 主題，自動 restow + reload）──
# 用法：
#   theme-switch            列出目前與可用主題
#   theme-switch <name>     切到該主題（本地沒有會自動從 origin 建立）
DOTFILES_DIR="$HOME/dotfiles"

theme-switch() {
  local dir="$DOTFILES_DIR"
  [[ -d "$dir/.git" ]] || { print -P "%F{$DAYBREAK_ERR}找不到 dotfiles：$dir%f"; return 1 }

  # 沒給參數 → 顯示目前與可用主題
  if [[ -z "$1" ]]; then
    print -P "目前主題：%F{$DAYBREAK_OK}$(git -C "$dir" symbolic-ref --short HEAD 2>/dev/null)%f"
    print "可用主題（本地）："
    git -C "$dir" branch --format='  %(refname:short)'
    return 0
  fi

  local target="$1"

  # 目標主題存在嗎？本地沒有就找 origin
  if ! git -C "$dir" show-ref --verify --quiet "refs/heads/$target"; then
    if git -C "$dir" show-ref --verify --quiet "refs/remotes/origin/$target"; then
      print -P "%F{$DAYBREAK_OK}從 origin 建立本地分支 $target%f"
      git -C "$dir" branch --track "$target" "origin/$target" || return 1
    else
      print -P "%F{$DAYBREAK_ERR}沒有這個主題：$target%f"
      git -C "$dir" branch -a
      return 1
    fi
  fi

  # 髒工作目錄處理（app 會直接寫進 repo，例如 nvim 的 lazy-lock.json）
  if [[ -n "$(git -C "$dir" status --porcelain)" ]]; then
    print -P "%F{$DAYBREAK_ERR}dotfiles 有未提交的改動：%f"
    git -C "$dir" status --short
    print -n "處理方式？[s]tash / [c]ommit / [d]iscard / [a]bort: "
    local ans; read -r ans
    case "$ans" in
      s) git -C "$dir" stash push -u -m "theme-switch auto-stash" || return 1 ;;
      c) git -C "$dir" add -A && git -C "$dir" commit -m "wip: before switching to $target" || return 1 ;;
      d) git -C "$dir" reset --hard && git -C "$dir" clean -fd ;;
      *) print "已取消。"; return 1 ;;
    esac
  fi

  # 切換主題（折疊目錄內的檔會立即生效）
  git -C "$dir" checkout "$target" || { print -P "%F{$DAYBREAK_ERR}checkout 失敗%f"; return 1 }

  # restow：補上新增/移除的頂層目錄 symlink；-R 可安全重複執行
  if command -v stow >/dev/null 2>&1; then
    if stow -R -d "$dir/pkgs" -t "$HOME" config home; then
      print -P "%F{$DAYBREAK_OK}stow restow 完成%f"
    else
      print -P "%F{$DAYBREAK_ERR}stow 有衝突，請看上面訊息手動處理%f"
    fi
  fi

  # reload 執行中的 app
  command -v hyprctl    >/dev/null 2>&1 && hyprctl reload >/dev/null 2>&1
  pgrep -x waybar       >/dev/null 2>&1 && killall -SIGUSR2 waybar 2>/dev/null
  pgrep -x xsettingsd   >/dev/null 2>&1 && killall -HUP xsettingsd 2>/dev/null
  command -v swaync-client >/dev/null 2>&1 && pgrep -x swaync >/dev/null 2>&1 && swaync-client -rs 2>/dev/null
  command -v xrdb       >/dev/null 2>&1 && xrdb -merge "$HOME/.Xresources" 2>/dev/null

  print -P "%F{$DAYBREAK_OK}已切換到主題：$target%f（nvim 與終端機請重開以套用）"
}

# tab 補全：補上本地與 origin 的主題分支
_theme-switch() {
  local -a themes
  themes=(${(f)"$(git -C "$DOTFILES_DIR" for-each-ref --format='%(refname:short)' refs/heads 2>/dev/null)"})
  themes+=(${(f)"$(git -C "$DOTFILES_DIR" for-each-ref --format='%(refname:short)' refs/remotes/origin 2>/dev/null | sed 's#^origin/##')"})
  compadd -- ${(u)themes:#HEAD}
}
compdef _theme-switch theme-switch
