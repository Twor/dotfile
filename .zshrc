case $TERM in
  (*xterm* | rxvt)

    # Write some info to terminal title.
    # This is seen when the shell prompts for input.
    function precmd {
      print -Pn "\e]0;%(1j,%j job%(2j|s|); ,)%~\a"
    }
    # Write command and args to terminal title.
    # This is seen while the shell waits for a command to complete.
    function preexec {
      printf "\033]0;%s\a" "$1"
    }

  ;;
esac
# Disable software flow control
stty -ixon

# Prompt theme
setopt prompt_subst
autoload -U colors && colors

prompt_color1="cyan"
prompt_color2="blue"

function prompt_git_status {
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ "$?" = "0" ]; then
        if [ -z "$(git status --porcelain)" ]; then
            prompt_color_git="green"
        else
            prompt_color_git="yellow"
        fi
        echo "%{$fg[$prompt_color2]$bg[$prompt_color_git]%}%{$reset_color%}%{$fg[black]$bg[$prompt_color_git]%} $branch %{$reset_color%}%{$fg[$prompt_color_git]%} %{$reset_color%}"
    else
        echo "%{$fg[$prompt_color2]%} %{$reset_color%}"
    fi
}


PROMPT=$'%
%{$fg[black]$bg[$prompt_color1]%} %n@%m %{$reset_color%}%
%{$fg[$prompt_color1]$bg[$prompt_color2]%}%{$reset_color%}%
%{$fg[black]$bg[$prompt_color2]%} %1~ %{$reset_color%}%
$(prompt_git_status)%
'

RPROMPT=$'%
%(?.%
%{$fg[white]%}%~%{$reset_color%}%
.%
%{$fg[red]%} %{$reset_color%}%
%{$fg[black]$bg[red]%} %? %{$reset_color%}%
)%
'

# Key bindings
bindkey -v
export KEYTIMEOUT=1
bindkey '^[[3~' delete-char

# Change cursor shape based on vi mode
function zle-keymap-select zle-line-init zle-line-finish {
    if [ "$KEYMAP" = "vicmd" ]; then
        echo -ne '\033[2 q'
    else
        echo -ne '\033[5 q'
    fi
}
zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=$HOME/.zsh_history
setopt histignorealldups sharehistory

# Aliases
source $HOME/.aliases

# Options
setopt autocd autopushd
setopt noflowcontrol

# Completion
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
setopt complete_aliases
source /usr/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh
source /usr/share/autojump/autojump.zsh

# source $HOME/.oh-my-zsh/plugins/fzf-tab/fzf-tab.plugin.zsh
# 当补全命令的开关时禁用排序
zstyle ':completion:complete:*:options' sort false

# 当补全 _zlua 时，使用输入作为查询字符串
#zstyle ':fzf-tab:complete:_zlua:*' query-string input

# （实验性功能）cd 时在右侧预览目录内容
local extract="
# 提取输入
in=\${\${\"\$(<{f})\"%\$'\0'*}#*\$'\0'}
# 获取相关信息
local -A ctxt=(\"\${(@ps:\2:)CTXT}\")
"
# 补全 `kill` 命令时提供命令行参数预览
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm,cmd -w -w"
zstyle ':fzf-tab:complete:kill:argument-rest' extra-opts --preview=$extract'ps --pid=$in[(w)1] -o cmd --no-headers -w -w' --preview-window=down:3:wrap

# 补全 cd 时使用 exa 预览其中的内容
zstyle ':fzf-tab:complete:cd:*' extra-opts --preview=$extract'exa -1 --color=always $realpath'
# Plugins
# source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh \
#     || git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions.git $HOME/.zsh/zsh-autosuggestions
# source $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
#     || git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.zsh/zsh-syntax-highlighting
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/fzf/key-bindings.zsh
source $HOME/.oh-my-zsh/plugins/fzf/fzf.plugin.zsh
export FZF_DEFAULT_COMMAND="fd --exclude={.git,.idea,.vscode,.sass-cache,node_modules,build,.icons,icons} --type f"
# export FZF_DEFAULT_COMMAND='fd --hidden --follow -E ".git" -E "node_modules" . /etc /home'
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --preview '(highlight -O ansi {} || cat {}) 2> /dev/null | head -500'"
