

# Sem o binário, sai quieto (nem toda máquina tem o pay-respects instalado)
command -v pay-respects >/dev/null || return 0

# Ativa o pay-respects
eval "$(pay-respects zsh --alias)"

__pr_base() {
    prefix=$(print -P "$PROMPT" 2>/dev/null)
    _PR_MODE="$1" _PR_PREFIX="$prefix" _PR_LAST_COMMAND="$2" _PR_ALIAS="`alias`" _PR_SHELL="zsh" "pay-respects"
}