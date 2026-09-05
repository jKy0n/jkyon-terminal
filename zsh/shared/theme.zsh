# Prompt Starship — binário externo (ver README/install.sh, check_pkg valida
# a instalação), tema em starship/starship.toml. Guarda com `command -v` pra
# não quebrar o shell numa máquina onde o binário ainda não foi instalado.
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
