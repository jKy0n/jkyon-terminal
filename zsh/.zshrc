#        Title:      .zshrc
#        Brief:      Dispatcher principal — decide perfil completo vs. mínimo
#

# Config da máquina atual (pode setar JKYON_HEADLESS=true, ex: Builder)
local host="${(L)HOST}"
[[ -r "$ZDOTDIR/machines/$host.zsh" ]] && source "$ZDOTDIR/machines/$host.zsh"

if [[ "$TERM" == "linux" || "$JKYON_HEADLESS" == "true" ]]; then
    source "$ZDOTDIR/minimal.zsh"
    return
fi

# ---------- Perfil completo ----------
[[ -r "$ZDOTDIR/secrets/api-keys.zsh" ]] && source "$ZDOTDIR/secrets/api-keys.zsh"

# Ordem é proposital, não alfabética — ver nota abaixo
local -a JKYON_MODULES=(theme plugins environment history keybinds alias vscode pay-respects tmux)
for module in "${JKYON_MODULES[@]}"; do
    [[ -r "$ZDOTDIR/shared/$module.zsh" ]] && source "$ZDOTDIR/shared/$module.zsh"
done

for func in "$ZDOTDIR/shared/functions"/*.zsh(N); do
    source "$func"
done
