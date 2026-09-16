#
#        Title:      tmp-claude-nopasswd.zsh
#        Brief:      Ativa/desativa NOPASSWD:ALL temporário (Claude Code) na
#                     máquina local, numa remota do parque, ou em todas —
#                     reaproveita GIT_SYNC_HOSTS de git.zsh.
#

typeset -g TMP_CLAUDE_NOPASSWD_SCRIPT="$HOME/ShellScript/Tools/tmp-claude-nopasswd/tmp-claude-nopasswd.sh"

#------------------------------------------------------------------------------
# _tmp-claude-nopasswd-local sub [duração]: roda o script na própria máquina.
#------------------------------------------------------------------------------
_tmp-claude-nopasswd-local() {
    local sub="$1" duration="$2"
    if [[ "$sub" == "on" ]]; then
        sudo "$TMP_CLAUDE_NOPASSWD_SCRIPT" on "$duration"
    else
        sudo "$TMP_CLAUDE_NOPASSWD_SCRIPT" "$sub"
    fi
}

#------------------------------------------------------------------------------
# _tmp-claude-nopasswd-remote host sub [duração]: roda via SSH. `on` precisa
# de tty (-t) pro prompt de senha do sudo aparecer; off/status não (só
# funcionam sem senha depois que o NOPASSWD já estiver ativo lá).
#------------------------------------------------------------------------------
_tmp-claude-nopasswd-remote() {
    local host="$1" sub="$2" duration="$3"

    if ! ssh -o BatchMode=yes -o ConnectTimeout=5 "$host" "test -x $TMP_CLAUDE_NOPASSWD_SCRIPT" 2>/dev/null; then
        print -P "%F{red}❌ [$host]%f script não encontrado em $TMP_CLAUDE_NOPASSWD_SCRIPT — o git-sync-all já rodou lá? (tente: git-sync shellscript)"
        return 1
    fi

    if [[ "$sub" == "on" ]]; then
        ssh -t "$host" "sudo $TMP_CLAUDE_NOPASSWD_SCRIPT on $duration"
    else
        ssh "$host" "sudo $TMP_CLAUDE_NOPASSWD_SCRIPT $sub"
    fi
}

#------------------------------------------------------------------------------
# tmp-claude-nopasswd [on|off|status] [DURAÇÃO]
# tmp-claude-nopasswd <host> [on|off|status] [DURAÇÃO]
# tmp-claude-nopasswd all [on|off|status] [DURAÇÃO]
#
# Sem host: local (comportamento de sempre). Com host ou "all", sem
# subcomando: implica "on". DURAÇÃO só faz sentido com "on" (sintaxe do
# systemd: "2h", "90min"; default 4h, ver TMP_CLAUDE_NOPASSWD_EXPIRE no
# próprio script).
#------------------------------------------------------------------------------
tmp-claude-nopasswd() {
    local first="$1"
    local -a targets=()
    local sub="on"

    case "$first" in
        on|off|status)
            shift
            _tmp-claude-nopasswd-local "$first" "$1"
            return $?
            ;;
        "")
            print -P "%F{red}❌ Erro:%f uso: tmp-claude-nopasswd [on|off|status] | <host> [on|off|status] [DURAÇÃO] | all [on|off|status] [DURAÇÃO]"
            print "Máquinas válidas: ${(j:, :)GIT_SYNC_HOSTS}"
            return 1
            ;;
        all)
            targets=("${GIT_SYNC_HOSTS[@]}")
            shift
            ;;
        *)
            if (( ${GIT_SYNC_HOSTS[(Ie)${(L)first}]} )); then
                targets=("${(L)first}")
                shift
            else
                print -P "%F{red}❌ Erro:%f '$first' não é host válido nem subcomando (on/off/status/all). Máquinas: ${(j:, :)GIT_SYNC_HOSTS}"
                return 1
            fi
            ;;
    esac

    case "$1" in
        on|off|status) sub="$1"; shift ;;
    esac
    local duration="$1"

    local host failed=0
    for host in "${targets[@]}"; do
        if [[ "${(L)host}" == "${(L)HOST}" ]]; then
            print -P "%F{blue}🖥️  [$host] local%f"
            if _tmp-claude-nopasswd-local "$sub" "$duration"; then
                print -P "%F{green}✅ [$host]%f"
            else
                print -P "%F{red}❌ [$host]%f"; failed=1
            fi
        else
            print -P "%F{blue}🔄 [$host] remoto%f"
            if _tmp-claude-nopasswd-remote "$host" "$sub" "$duration"; then
                print -P "%F{green}✅ [$host]%f"
            else
                print -P "%F{red}❌ [$host]%f"; failed=1
            fi
        fi
    done
    return "$failed"
}
