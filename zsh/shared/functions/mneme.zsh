#
#        Title:      mneme.zsh
#        Brief:      Abre a Mneme (Claude Code no vault ~/Documents/Obsidian/mneme).
#        Path:       ~/.config/zsh/shared/functions/mneme.zsh
#        Notes:      O vault e o git só existem na TheseusMachine: lá roda local,
#                     em qualquer outra máquina entra via SSH (nada fica gravado
#                     no escritório). zsh -lc no remoto = PATH de login sem
#                     carregar o .zshrc inteiro (zellij etc.). Argumentos vão
#                     direto pro claude (ex: mneme --continue).
#

mneme() {
    local cmd="cd ~/Documents/Obsidian/mneme && exec claude ${(j: :)${(q)@}}"

    if [[ "${(L)HOST}" == "theseusmachine" ]]; then
        (cd ~/Documents/Obsidian/mneme && claude "$@")
    else
        ssh -t theseusmachine "zsh -lc ${(q)cmd}"
    fi
}
