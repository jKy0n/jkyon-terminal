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

#------------------------------------------------------------------------------
# _git-dashboard-local-state <repo_path>: estado do repo NESTA máquina.
#                                          Só leitura: fetch + status
#                                          --porcelain + rev-list --count.
#                                          Nunca faz pull/push.
#------------------------------------------------------------------------------
_git-dashboard-local-state() {
    local repo_path="$1" dirty ahead behind

    [[ ! -d "$repo_path/.git" ]] && { echo "missing"; return }

    git -C "$repo_path" fetch --quiet 2>/dev/null
    dirty=""
    [[ -n "$(git -C "$repo_path" status --porcelain 2>/dev/null)" ]] && dirty=1
    ahead="$(git -C "$repo_path" rev-list --count '@{u}..HEAD' 2>/dev/null)"
    behind="$(git -C "$repo_path" rev-list --count 'HEAD..@{u}' 2>/dev/null)"
    ahead="${ahead:-0}"; behind="${behind:-0}"

    if [[ -n "$dirty" ]]; then
        echo "dirty"
    elif [[ "$ahead" -gt 0 && "$behind" -gt 0 ]]; then
        echo "diverged"
    elif [[ "$ahead" -gt 0 ]]; then
        echo "ahead"
    elif [[ "$behind" -gt 0 ]]; then
        echo "behind"
    else
        echo "clean"
    fi
}

#------------------------------------------------------------------------------
# _git-dashboard-host-scan <host> <nome1> [nome2 ...]: mesma lógica acima,
#                          mas pra uma máquina remota — numa ÚNICA conexão
#                          SSH (não uma por repo), rodando um laço do lado
#                          de lá. Imprime uma linha "nome:estado" por repo.
#                          Só leitura, igual à versão local.
#------------------------------------------------------------------------------
_git-dashboard-host-scan() {
    local host="$1"; shift
    local name

    # Script + dados vão juntos por um ÚNICO stdin (sem passar nada por
    # argumento de linha de comando): o ssh junta os argv e reenvia pro
    # shell remoto interpretar de novo, o que quebra qualquer separador
    # (`;`, espaço) que os dados tenham. Indo tudo pelo stdin, o `while
    # read` do script consome exatamente as linhas de dados anexadas
    # depois do `done` — o bash já terá parseado o laço inteiro antes de
    # executá-lo, então o `read` sobra pra ler só o que vier a seguir.
    {
        cat <<'REMOTE'
while IFS='=' read -r name path; do
    [[ -z "$name" ]] && continue
    if [[ ! -d "$path/.git" ]]; then
        echo "$name:missing"
        continue
    fi
    git -C "$path" fetch --quiet 2>/dev/null
    dirty=""
    [[ -n "$(git -C "$path" status --porcelain 2>/dev/null)" ]] && dirty=1
    ahead="$(git -C "$path" rev-list --count '@{u}..HEAD' 2>/dev/null)"
    behind="$(git -C "$path" rev-list --count 'HEAD..@{u}' 2>/dev/null)"
    ahead="${ahead:-0}"; behind="${behind:-0}"
    if [[ -n "$dirty" ]]; then
        echo "$name:dirty"
    elif [[ "$ahead" -gt 0 && "$behind" -gt 0 ]]; then
        echo "$name:diverged"
    elif [[ "$ahead" -gt 0 ]]; then
        echo "$name:ahead"
    elif [[ "$behind" -gt 0 ]]; then
        echo "$name:behind"
    else
        echo "$name:clean"
    fi
done
REMOTE
        for name in "$@"; do
            print -r -- "${name}=${GIT_SYNC_REPOS[$name]}"
        done
    } | ssh -o BatchMode=yes -o ConnectTimeout=5 "$host" bash 2>/dev/null
}

#------------------------------------------------------------------------------
# _git-dashboard-symbol <estado>: símbolo colorido de 1 caractere por estado
#                                  (estreito de propósito — emoji largo
#                                  desalinha a tabela em terminal).
#------------------------------------------------------------------------------
_git-dashboard-symbol() {
    case "$1" in
        clean)       print -nP "%F{green}✔%f" ;;
        dirty)       print -nP "%F{yellow}✎%f" ;;
        ahead)       print -nP "%F{cyan}↑%f" ;;
        behind)      print -nP "%F{cyan}↓%f" ;;
        diverged)    print -nP "%F{red}⇕%f" ;;
        unreachable) print -nP "%F{red}✕%f" ;;
        *)           print -nP "%F{8}·%f" ;;
    esac
}

#------------------------------------------------------------------------------
# git-dashboard [nome]: painel repo × máquina. Linha = repo registrado em
#                        GIT_SYNC_REPOS, coluna = máquina de GIT_SYNC_HOSTS,
#                        célula = estado do git ali. Só leitura (fetch, sem
#                        pull/push) — é diagnóstico, não sincronização; pra
#                        corrigir o que aparecer, vá até a máquina/repo.
#------------------------------------------------------------------------------
git-dashboard() {
    local target="$1" name repo_path host local_host
    typeset -A DASH

    if [[ -n "$target" && -z "${GIT_SYNC_REPOS[$target]}" ]]; then
        print -P "%F{red}❌ Erro:%f '$target' não registrado. Opções: ${(k)GIT_SYNC_REPOS}"
        return 1
    fi

    local -a repos=()
    for name repo_path in "${(@kv)GIT_SYNC_REPOS}"; do
        [[ -n "$target" && "$name" != "$target" ]] && continue
        repos+=("$name")
    done

    # nome desta máquina exatamente como aparece em GIT_SYNC_HOSTS
    # (comparação case-insensitive, pra bater com $HOST do sistema)
    local_host="$HOST"
    for host in "${GIT_SYNC_HOSTS[@]}"; do
        [[ "${(L)host}" == "${(L)HOST}" ]] && { local_host="$host"; break }
    done

    for name in "${repos[@]}"; do
        DASH["$name|$local_host"]="$(_git-dashboard-local-state "${GIT_SYNC_REPOS[$name]}")"
    done

    local out state_line n st
    for host in "${GIT_SYNC_HOSTS[@]}"; do
        [[ "$host" == "$local_host" ]] && continue
        out="$(_git-dashboard-host-scan "$host" "${repos[@]}")"
        while IFS=: read -r n st; do
            [[ -z "$n" ]] && continue
            DASH["$n|$host"]="$st"
        done <<< "$out"
        for name in "${repos[@]}"; do
            [[ -z "${DASH["$name|$host"]}" ]] && DASH["$name|$host"]="unreachable"
        done
    done

    # larguras de coluna calculadas sobre texto puro (nunca sobre o texto
    # já colorido — senão os códigos ANSI entram na conta e desalinha)
    local repo_w=4
    for name in "${repos[@]}"; do
        (( ${#name} > repo_w )) && repo_w="${#name}"
    done
    typeset -A HOST_W
    for host in "${GIT_SYNC_HOSTS[@]}"; do
        HOST_W[$host]="${#host}"
        (( HOST_W[$host] < 3 )) && HOST_W[$host]=3
    done

    printf '%-*s' "$repo_w" "repo"
    for host in "${GIT_SYNC_HOSTS[@]}"; do
        printf '  %-*s' "${HOST_W[$host]}" "$host"
    done
    print

    local pad state sym
    for name in "${repos[@]}"; do
        printf '%-*s' "$repo_w" "$name"
        for host in "${GIT_SYNC_HOSTS[@]}"; do
            state="${DASH["$name|$host"]:-missing}"
            print -n "  "
            _git-dashboard-symbol "$state"
            pad=$(( HOST_W[$host] - 1 ))
            (( pad > 0 )) && printf '%*s' "$pad" ""
        done
        print
    done

    print
    print -P "%F{green}✔%f ok   %F{yellow}✎%f sujo   %F{cyan}↑%f à frente (push)   %F{cyan}↓%f atrás (pull)   %F{red}⇕%f divergente   %F{red}✕%f inacessível   %F{8}·%f n/a"
}
