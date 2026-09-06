_jkyon_zellij_autostart() {
    # Roda de novo em todo precmd até o zellij realmente iniciar (ou condição não bater).
    # Necessário porque plugins turbo (zinit ice wait) podem reatribuir
    # $precmd_functions inteiro depois do nosso registro, apagando o hook
    # antes dele disparar — isso resolve o hook sozinho, sem depender de ordem.

    if [[ -n "$ZELLIJ" ]] || [[ -n "$NO_MUX" ]]; then
        add-zsh-hook -d precmd _jkyon_zellij_autostart
        return
    fi

    if [[ -t 0 ]] && \
        [[ -x "$(command -v zellij)" ]] && \
        [[ $- == *i* ]] && \
        [[ "$TERM_PROGRAM" != "vscode" ]]; then

        add-zsh-hook -d precmd _jkyon_zellij_autostart

        if ! zellij; then
            echo "Erro ao iniciar sessão zellij!"
        fi
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _jkyon_zellij_autostart
