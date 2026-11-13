#
#        Title:      incubadora.zsh
#        Brief:      Incubadora de binpkgs (systemd-nspawn) de qualquer máquina do parque.
#        Path:       ~/.config/zsh/shared/functions/incubadora.zsh
#        Notes:      Os chroots vivem na TheseusMachine (/mnt/incubadora, desde
#                     2026-11-13). Lá roda local; em qualquer outra máquina entra
#                     via SSH, dentro de um tmux por alvo (incubadora-<alvo>): se o
#                     SSH cair ou o terminal fechar, o emerge segue rodando, e
#                     chamar de novo reentra na mesma sessão (o nspawn só abre uma
#                     instância por alvo de qualquer jeito). Se a sessão já existe,
#                     o comando novo é ignorado e você só reentra nela.
#
#          incubadora viamar-pc                     -> shell na incubadora
#          incubadora viamar-pc update              -> emerge -pvuDN @world
#          incubadora viamar-pc upgrade [args]      -> emerge -avuDN @world [args]
#          incubadora viamar-pc emerge -1 foo/bar   -> qualquer comando
#          incubadora-sync                          -> sync dos overlays restritos
#

typeset -g INCUBADORA_HOST="theseusmachine"
typeset -g INCUBADORA_SCRIPT="$HOME/ShellScript/TheseusMachine/scripts/incubadora/incubadora.sh"

incubadora() {
    if [[ "${(L)HOST}" == "$INCUBADORA_HOST" ]]; then
        sudo "$INCUBADORA_SCRIPT" "$@"
        return
    fi

    local session="incubadora-${1:-sem-alvo}"
    # A pausa no fim segura a tela: sem ela o tmux fecha a sessão junto com o
    # comando e a saída (ex.: a lista do update) some antes de ser lida.
    local cmd="sudo $INCUBADORA_SCRIPT ${(j: :)${(q)@}}; rc=\$?; printf '\\n[incubadora] fim (rc=%s). Enter fecha. ' \$rc; read _"
    ssh -t "$INCUBADORA_HOST" "tmux new-session -A -s ${(q)session} ${(q)cmd}"
}

# Overlays que só existem dentro da incubadora (gentoo/guru/jkyon-overlay vêm do host)
incubadora-sync() {
    incubadora viamar-pc emerge --sync CachyOS-kernels parona-overlay xarblu-overlay
}
