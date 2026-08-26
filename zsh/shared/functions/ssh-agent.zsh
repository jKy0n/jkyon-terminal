# ~/.jkyon-terminal/zsh/shared/functions/ssh-agent.zsh


# 1. Tenta herdar variáveis do systemd (PAM/Gnome-Keyring/SSH)
#    Retry curto: logo após login SSH, o systemd --user pode ainda não
#    ter processado environment.d/D-Bus. 3 tentativas, 100ms entre elas.
if [[ ! -S "$SSH_AUTH_SOCK" ]] && command -v systemctl >/dev/null 2>&1; then
    for _try in 1 2 3; do
        eval $(systemctl --user show-environment | grep -E '^(GNOME_KEYRING|SSH_AUTH_SOCK|DBUS_SESSION_BUS_ADDRESS)')
        export GNOME_KEYRING_CONTROL SSH_AUTH_SOCK DBUS_SESSION_BUS_ADDRESS
        [[ -S "$SSH_AUTH_SOCK" ]] && break
        sleep 0.1
    done
    unset _try
fi

# 2. Se após a tentativa do systemd o socket ainda não existir, usa o keychain
if [[ ! -S "$SSH_AUTH_SOCK" ]]; then
    if command -v keychain >/dev/null 2>&1; then
        eval $(keychain --eval --quiet Viamar-GitHub)
    fi
fi

# 3. GPG_TTY: obrigatório pro pinentry saber onde desenhar o prompt de senha.
#    Sem isso, toda operação de assinatura via gpg-agent falha silenciosamente
#    ("agent refused operation"), mesmo com a chave carregada e o socket certo.
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
