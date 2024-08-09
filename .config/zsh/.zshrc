# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Zinit stuff
# if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
#     print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
#     command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
#     command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
#         print -P "%F{33} %F{34}Installation successful.%f%b" || \
#         print -P "%F{160} The clone has failed.%f%b"
# fi

declare -gAH ZINIT
declare -U path
path=($HOME/.local/bin $HOME/.local/bin/flutter/bin $path)
export PATH
export GTK_IM_MODULE=ibus
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
ZINIT[HOME_DIR]=$HOME/.local/share/zinit
ZINIT[BIN_DIR]=$ZINIT[HOME_DIR]/zinit.git
ZINIT[COMPLETIONS_DIR]=$ZINIT[HOME_DIR]/completions 
ZINIT[SNIPPETS_DIR]=$ZINIT[HOME_DIR]/snippets
ZINIT[ZCOMPDUMP_PATH]=$ZINIT[HOME_DIR]/zcompdump    
ZINIT[PLUGINS_DIR]=$ZINIT[HOME_DIR]/plugins
ZINIT[OPTIMIZE_OUT_DISK_ACCESSES]=1
ZINIT[COMPINIT_OPTS]='-C'

ZPFX="$HOME/.local"
source "${ZINIT_HOME}/zinit.zsh"
bindkey '^[|' zsh_gh_copilot_explain  # bind Alt+shift+\ to explain
bindkey '^[\' zsh_gh_copilot_suggest  # bind Alt+\ to suggest
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# fzf opts
export FZF_DEFAULT_OPTS="
--layout=reverse
--info=inline
--height=40%
--preview-window=:hidden,right,50%
--multi
--preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (ls -1 --color=always{})) || echo {} 2> /dev/null | head -200'
--color='hl:148,hl+:154,pointer:032,marker:010,bg+:237,gutter:008'
--prompt='❯ ' --pointer='➔' --marker='✓'
--bind 'ctrl-/:toggle-preview'
--bind 'ctrl-a:select-all'
--bind 'ctrl-e:execute(echo {+} | xargs -o vim)'
--bind 'ctrl-v:execute(code {+})'
"
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
setopt glob_dots

### fzf_tab opts
# key bind
zstyle ':fzf-tab:complete:*' fzf-bindings \
	'ctrl-v:execute-silent({_FTB_INIT_}code "$realpath")' \
	'ctrl-a:select-all'
zstyle ':completion:*' menu select

# systemctl preview
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'
zstyle ':fzf-tab:complete:*' fzf-preview '([[ -f $realpath ]] && (bat --style=numbers --color=always $realpath || cat $realpath)) || ([[ -d $realpath ]] && (ls -1 --color=always $realpath)) || echo $realpath 2> /dev/null | head -200'
zstyle ':fzf-tab:*' ignore 4

# kill preview
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
  '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap

# history opt
HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=10000
SAVEHIST=5000
setopt appendhistory 

setopt bang_hist                # Treat The '!' Character Specially During Expansion.
setopt inc_append_history       # Write To The History File Immediately, Not When The Shell Exits.
setopt share_history            # Share History Between All Sessions.
setopt hist_find_no_dups        # Do Not Display A Previously Found Event.
setopt hist_ignore_space        # Do Not Record An Event Starting With A Space.
setopt hist_save_no_dups        # Do Not Write A Duplicate Event To The History File.
setopt hist_verify              # Do Not Execute Immediately Upon History Expansion.
setopt extended_history         # Show Timestamp In History.

### plugins
zinit light zdharma-continuum/zinit-annex-binary-symlink

zinit ice depth'1'
zinit light romkatv/powerlevel10k

#bunch of completions and snippet
zinit wait'0a' lucid light-mode depth"1" for \
  atpull'zinit creinstall -q .' blockf zsh-users/zsh-completions \
  pick"shell/key-bindings.zsh" id-as"fzf_keybind" junegunn/fzf \
  as"completion" id-as"chezmoi_completion" nocompile \
  has"chezmoi" atclone"chezmoi completion zsh > _chezmoi" pick"_chezmoi" zdharma-continuum/null

#bunch of binary and their completions
zinit light-mode wait'0a' lucid from'gh-r' lbin'!' nocompile for \
  @junegunn/fzf \
  @sharkdp/fd \
  atclone"**/bin/gh completion --shell zsh > _gh" lbin'!**/bin/gh' @cli/cli \
  lbin'!**/rg' @BurntSushi/ripgrep \
  atclone"./topgrade --gen-completion zsh > _topgrade" @topgrade-rs/topgrade \
  mv"bat*/autocomplete/bat.zsh -> _bat" @sharkdp/bat

ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=50

zinit light-mode wait'0b' lucid depth"1" for \
    atinit'zicompinit; zpcdreplay' Aloxaf/fzf-tab \
    atload"_zsh_autosuggest_start" zsh-users/zsh-autosuggestions

#bunch of lazy load plug, they don't need load early and no completion from them
ZSHZ_DATA="$ZDOTDIR/.z"
zinit light-mode wait'0c' lucid for \
    OMZP::extract \
    agkozak/zsh-z 

# To customize prompt, run `p10k configure` or edit ${ZDOTDIR}/.p10k.zsh.
[[ ! -f ${ZDOTDIR}/.p10k.zsh ]] || source ${ZDOTDIR}/.p10k.zsh

if [ -f "${HOME}/.local/bin/micromamba" ]; then
    export MAMBA_EXE="${HOME}/.local/bin/micromamba"
    export MAMBA_ROOT_PREFIX="${HOME}/micromamba"
    alias micromamba="$MAMBA_EXE"
fi

