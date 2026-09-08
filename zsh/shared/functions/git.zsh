#
#        Title:      git.zsh
#        Brief:      Funções git genéricas — funciona com qualquer repo registrado (ShellScript, jkyon-terminal, etc.)
#

typeset -gA GIT_SYNC_REPOS=(
    ai-context   "$HOME/.jkyon-ai-context"
    nvim         "$HOME/.config/nvim"
    shellscript  "$HOME/ShellScript"
    systemd      "/etc/jkyon-systemd"
    terminal     "$HOME/.jkyon-terminal"
    zed          "$HOME/.config/zed"
)

typeset -ga GIT_SYNC_HOSTS=(
    theseusmachine
    viamar-pc
    crisnote
    builder
)

#------------------------------------------------------------------------------
# git-cp: commit + push do repo atual, qualquer um que seja.
#------------------------------------------------------------------------------
git-cp() {
    if [[ -z "$1" ]]; then
        print -P "%F{red}❌ Erro:%f Faltou a mensagem de commit."
        print "Uso correto: git-cp \"sua mensagem\""
        return 1
    fi
    git commit -am "$*" && git push
}

#------------------------------------------------------------------------------
# _git-sync-detect: descobre qual repo registrado corresponde ao $PWD atual.
#------------------------------------------------------------------------------
_git-sync-detect() {
    local name repo_path
    for name repo_path in "${(@kv)GIT_SYNC_REPOS}"; do
        [[ "$PWD" == "$repo_path"* ]] && { echo "$name"; return 0; }
    done
    return 1
}

#------------------------------------------------------------------------------
# git-cp-sync: commit + push do repo atual, e sincroniza esse MESMO repo
#              nas outras máquinas — detecta o alvo sozinho pelo $PWD.
#------------------------------------------------------------------------------
git-cp-sync() {
    git-cp "$@" || return 1
    local target
    if target="$(_git-sync-detect)"; then
        git-sync "$target"
    else
        print -P "%F{yellow}⚠️  Repo atual não está em GIT_SYNC_REPOS — pulei o sync remoto.%f"
    fi
}

#------------------------------------------------------------------------------
# git-status: pull + status local. Sem argumento, usa o repo do $PWD.
#------------------------------------------------------------------------------
git-status() {
    local repo="${1:-$PWD}"
    print -P "%F{cyan}🔄 Atualizando:%f $repo"
    git -C "$repo" pull --ff-only || return 1
    print
    git -C "$repo" status -sb
}

#------------------------------------------------------------------------------
# Helpers internos via SSH.
#------------------------------------------------------------------------------
_git-sync-remote() {
    local host="$1" repo_path="$2"
    ssh -o BatchMode=yes -o ConnectTimeout=5 "$host" "cd $repo_path && git pull --ff-only" >/dev/null 2>&1
    local local_hash remote_hash
    local_hash="$(git -C "$repo_path" rev-parse HEAD 2>/dev/null)"
    remote_hash="$(ssh -o BatchMode=yes -o ConnectTimeout=5 "$host" "git -C $repo_path rev-parse HEAD" 2>/dev/null)"
    [[ -n "$remote_hash" && "$local_hash" == "$remote_hash" ]]
}

_git-status-remote() {
    local host="$1" repo_path="$2"
    ssh -o BatchMode=yes -o ConnectTimeout=5 "$host" "cd $repo_path && git pull --ff-only --quiet && git status -sb" 2>&1
    local local_hash remote_hash
    local_hash="$(git -C "$repo_path" rev-parse HEAD 2>/dev/null)"
    remote_hash="$(ssh -o BatchMode=yes -o ConnectTimeout=5 "$host" "git -C $repo_path rev-parse HEAD" 2>/dev/null)"
    [[ -n "$remote_hash" && "$local_hash" == "$remote_hash" ]]
}

#------------------------------------------------------------------------------
# _git-local-sync-check: garante que o HEAD local está em dia com o origin
#                         antes de qualquer comparação de hash remota.
#                         behind -> resolve sozinho (pull --ff-only).
#                         ahead  -> NÃO resolve sozinho (evita push cego de
#                                   código não revisado); só avisa e retorna 1.
#------------------------------------------------------------------------------
_git-local-sync-check() {
    local name="$1" repo_path="$2" ahead behind

    git -C "$repo_path" fetch --quiet 2>/dev/null
    ahead="$(git -C "$repo_path" rev-list --count '@{u}..HEAD' 2>/dev/null)"
    behind="$(git -C "$repo_path" rev-list --count 'HEAD..@{u}' 2>/dev/null)"

    if [[ "$ahead" -gt 0 ]]; then
        print -P "%F{red}⚠️  [$name] local está $ahead commit(s) à frente do origin — dá 'git -C $repo_path push' antes de sincronizar%f"
        return 1
    fi

    [[ "$behind" -gt 0 ]] && git -C "$repo_path" pull --ff-only --quiet
    return 0
}

#------------------------------------------------------------------------------
# git-sync [nome]: sem argumento, sincroniza TODOS os repos registrados em
#                  todas as máquinas. Com argumento, só aquele repo.
#------------------------------------------------------------------------------
git-sync() {
    local target="$1" name repo_path host failed=0

    if [[ -n "$target" && -z "${GIT_SYNC_REPOS[$target]}" ]]; then
        print -P "%F{red}❌ Erro:%f '$target' não registrado. Opções: ${(k)GIT_SYNC_REPOS}"
        return 1
    fi

    for name repo_path in "${(@kv)GIT_SYNC_REPOS}"; do
        [[ -n "$target" && "$name" != "$target" ]] && continue
        _git-local-sync-check "$name" "$repo_path" || { failed=1; continue }
        for host in "${GIT_SYNC_HOSTS[@]}"; do
            if [[ "${(L)host}" == "${(L)HOST}" ]]; then
                print; print -P "%F{yellow}⏭️  [$name] $host é esta máquina, pulando%f"
                continue
            fi
            print; print -P "%F{blue}🔄 [$name] Atualizando $host...%f"
            if _git-sync-remote "$host" "$repo_path"; then
                print -P "%F{green}✅ $host atualizado%f"
            else
                print -P "%F{red}❌ $host falhou%f"; failed=1
            fi
        done
    done
    return "$failed"
}

#------------------------------------------------------------------------------
# git-status-all [nome]: mesmo padrão do git-sync, mas só mostra status.
#------------------------------------------------------------------------------
git-status-all() {
    local target="$1" name repo_path host failed=0

    for name repo_path in "${(@kv)GIT_SYNC_REPOS}"; do
        [[ -n "$target" && "$name" != "$target" ]] && continue
        _git-local-sync-check "$name" "$repo_path" || { failed=1; continue }
        for host in "${GIT_SYNC_HOSTS[@]}"; do
            if [[ "${(L)host}" == "${(L)HOST}" ]]; then
                print; print -P "%F{yellow}⏭️  [$name] $host é esta máquina, pulando%f"
                continue
            fi
            print; print -P "%F{blue}🖥️  [$name] $host%f"
            _git-status-remote "$host" "$repo_path" || { print -P "%F{red}❌ $host falhou%f"; failed=1; }
        done
    done
    return "$failed"
}
