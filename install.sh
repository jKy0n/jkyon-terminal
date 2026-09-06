#!/usr/bin/env bash
set -euo pipefail

REPO="$HOME/.jkyon-terminal"
cd "$REPO"

echo "== jkyon-terminal install =="

# 1. Tráfego real por SSH, sem exigir isso de quem só clona pra ver o repo
git config url."git@github.com:".insteadOf "https://github.com/"

# 2. Plugins vendorizados (fzf-tab, autosuggestions, syntax-highlighting, TPM)
git submodule update --init --recursive

# 3. Destrava os secrets — falha graciosamente se esta máquina ainda não
#    foi autorizada (ex: CrisNote, antes do add-gpg-user dela)
if command -v git-crypt >/dev/null 2>&1; then
    if git-crypt unlock 2>/dev/null; then
        echo "🔓 secrets desbloqueados"
    else
        echo "⚠️  git-crypt unlock falhou — máquina ainda não autorizada ou GPG não pronto."
        echo "   Secrets continuam cifrados; o resto do install segue normal."
    fi
else
    echo "⚠️  git-crypt não instalado — pulei o unlock."
fi

# 4. Aposenta o ~/.zshrc antigo — órfão a partir de agora, porque o ~/.zshenv
#    que vamos linkar redireciona o zsh pra procurar .zshrc dentro do ZDOTDIR,
#    não mais direto em $HOME. Deixar o antigo aí só confundiria depois.
if [[ -e "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
    mv "$HOME/.zshrc" "$HOME/.zshrc.pre-jkyon-terminal.bak"
    echo "📦 ~/.zshrc antigo preservado em ~/.zshrc.pre-jkyon-terminal.bak (agora órfão, sem função)"
fi

# 5. Symlinks — idempotente, com backup do que já existir de verdade
link() {
    local src="$1" dst="$2"
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        mv "$dst" "$dst.bak.$(date +%Y%m%d%H%M%S)"
        echo "📦 backup: $dst"
    fi
    ln -sfn "$src" "$dst"
    echo "🔗 $dst → $src"
}

link "$REPO/zsh"                       "$HOME/.config/zsh"
link "$REPO/tmux"                      "$HOME/.config/tmux"
link "$REPO/alacritty"                 "$HOME/.config/alacritty"
link "$REPO/kitty"                     "$HOME/.config/kitty"
link "$REPO/zellij"                    "$HOME/.config/zellij"
link "$REPO/zsh/.zshenv"               "$HOME/.zshenv"
link "$REPO/starship/starship.toml"    "$HOME/.config/starship.toml"

# 6. Binários de sistema — checa e sugere, nunca instala sozinho sem você mandar
check_pkg() {
    local bin="$1" arch_pkg="$2" gentoo_hint="$3"
    if command -v "$bin" >/dev/null 2>&1; then
        echo "✅ $bin já instalado"
        return
    fi
    echo "❌ $bin não encontrado."
    if command -v pacman >/dev/null 2>&1; then
        echo "   sugestão: sudo pacman -S $arch_pkg"
    elif command -v emerge >/dev/null 2>&1; then
        echo "   sugestão: emerge -s $bin   # confirma a categoria certa antes de instalar ($gentoo_hint)"
    else
        echo "   gerenciador de pacote não identificado — instale $bin manualmente."
    fi
}

check_pkg fzf      fzf      "provavelmente app-shells/fzf"
check_pkg zoxide   zoxide   "provavelmente app-shells/zoxide"
check_pkg atuin    atuin    "pode precisar do overlay GURU, confirme antes"
check_pkg kitty    kitty    "provavelmente x11-terms/kitty"
check_pkg starship starship "provavelmente app-shells/starship, ou 'cargo install starship'"

# kitty-terminfo é diferente dos outros: não instala binário nenhum, só uma
# entry de terminfo. command -v não serve pra detectar isso — precisa checar
# via infocmp se a entry xterm-kitty já existe no sistema.
if infocmp xterm-kitty >/dev/null 2>&1; then
    echo "✅ terminfo xterm-kitty já presente"
else
    echo "❌ terminfo xterm-kitty não encontrado."
    if command -v pacman >/dev/null 2>&1; then
        echo "   sugestão: sudo pacman -S kitty-terminfo"
    elif command -v emerge >/dev/null 2>&1; then
        echo "   sugestão: emerge -s kitty-terminfo   # x11-terms/kitty-terminfo"
    else
        echo "   gerenciador de pacote não identificado — instale kitty-terminfo manualmente."
    fi
    echo "   alternativa sem instalar nada: use 'kitten ssh' no lugar de 'ssh' —"
    echo "   ele copia o terminfo pro remoto automaticamente na conexão."
fi

echo "== Concluído. Abra um terminal novo pra aplicar. =="