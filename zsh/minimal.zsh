#
#        Title:      minimal.zsh
#        Brief:      Perfil mínimo — TTY físico do kernel OU máquina headless
#

source "$ZDOTDIR/shared/environment.zsh"
source "$ZDOTDIR/shared/history.zsh"
source "$ZDOTDIR/shared/keybinds.zsh"
[[ -r "$ZDOTDIR/secrets/api-keys.zsh" ]] && source "$ZDOTDIR/secrets/api-keys.zsh"

# Completion básica — sem fzf-tab: depende do binário fzf e de um
# terminal mais capaz do que o console do kernel costuma oferecer.
local zcompdump_d="${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
[[ -d "$zcompdump_d" ]] || mkdir -p "$zcompdump_d"
autoload -Uz compinit
compinit -d "$zcompdump_d/zcompdump"
setopt COMPLETE_ALIASES

# autosuggestions e syntax-highlighting são scripts zsh puros, sem
# depender de nerd-font/truecolor — funcionam normalmente no console.
ZSH_PLUGINS_D="$ZDOTDIR/plugins"
[[ -r "$ZSH_PLUGINS_D/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$ZSH_PLUGINS_D/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -r "$ZSH_PLUGINS_D/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && source "$ZSH_PLUGINS_D/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[[ -r "$ZDOTDIR/shared/highlight-overrides.zsh" ]] && source "$ZDOTDIR/shared/highlight-overrides.zsh"

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v atuin  >/dev/null 2>&1 && eval "$(atuin init zsh)"

# Console do kernel não tem glyphs de nerd-font — usa config ASCII-safe do
# Starship em vez da variante completa (equivalente ao antigo
# POWERLEVEL9K_MODE='ascii').
export STARSHIP_CONFIG="$ZDOTDIR/../starship/starship-minimal.toml"
source "$ZDOTDIR/shared/theme.zsh"

[[ -r "$ZDOTDIR/shared/functions/git.zsh" ]] && source "$ZDOTDIR/shared/functions/git.zsh"
[[ -r "$ZDOTDIR/shared/functions/ssh-agent.zsh" ]] && source "$ZDOTDIR/shared/functions/ssh-agent.zsh"
[[ -r "$ZDOTDIR/shared/alias.zsh" ]] && source "$ZDOTDIR/shared/alias.zsh"
[[ -r "$ZDOTDIR/shared/tmux.zsh" ]] && source "$ZDOTDIR/shared/tmux.zsh"
