# 🖥️ jkyon-terminal

![jkyon-terminal screenshot](docs/screenshot-2026-08-07.png)

> Ambiente de terminal unificado — **zsh** + **tmux** + **Alacritty** — com o mesmo comportamento em qualquer uma das minhas máquinas, seja Arch ou Gentoo, com GUI ou apenas SSH.

## 📋 Overview

Esse repositório substitui a necessidade de configurar zsh/tmux/Alacritty do zero em cada máquina nova. Um `git clone` + `./install.sh` e está pronto:

- 🔌 **Plugins vendorizados** como git submodules — o mesmo commit exato roda em qualquer distro, sem depender de qual versão o gerenciador de pacotes decidiu empacotar.
- 🔐 **Secrets cifrados** com `git-crypt`, seguros mesmo com o repositório público.
- 🖥️ **Perfil completo ou mínimo**, detectado automaticamente — TTY físico ou máquina headless caem num modo leve, sem ícones nem plugins pesados.
- 🎨 Tema **Catppuccin** (Frappe) consistente entre o prompt (Powerlevel10k), a barra do tmux e o terminal.

## 🚀 Instalação

**Dependências** (instale antes de clonar):

| Ferramenta | Papel |
|---|---|
| `git` | controle de versão |
| `git-crypt` | decifra os secrets |
| `gnupg` | chave usada pelo git-crypt |
| `fzf` | completion fuzzy (perfil completo) |
| `zoxide` | navegação inteligente de diretórios |
| `atuin` | histórico com busca fuzzy |
| Fonte Nerd Font | ícones do prompt e da barra do tmux |

```bash
git clone git@github.com:jKy0n/jkyon-terminal.git ~/.jkyon-terminal
cd ~/.jkyon-terminal
./install.sh
```

O script cuida de: symlinks pra `~/.config/{zsh,tmux,alacritty}` e `~/.zshenv` (com backup automático do que já existir), inicialização dos submodules, tentativa de `git-crypt unlock`, e checagem dos pacotes de sistema.

> **Fez fork?** Sem os secrets nem sem estar autorizado no git-crypt, tudo funciona normalmente — só o conteúdo de `zsh/secrets/` fica ilegível. Veja a seção de criptografia abaixo pra configurar o seu.

## 🔌 Plugins

**zsh** (submodules, path idêntico em qualquer distro):
- [powerlevel10k](https://github.com/romkatv/powerlevel10k) — prompt
- [fzf-tab](https://github.com/Aloxaf/fzf-tab) — completion fuzzy
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)

**tmux** (TPM como submodule; o resto instalado por ele via `prefix + I`):
- [catppuccin/tmux](https://github.com/catppuccin/tmux) — tema
- tmux-sensible, tmux-better-mouse-mode

**Binários de sistema** (não são plugins vendorizáveis, `install.sh` verifica): `fzf`, `zoxide`, `atuin`

## 🔐 Criptografia

Os arquivos em `zsh/secrets/` (API keys, hosts internos de distcc) são cifrados com **git-crypt + GPG** — cada máquina autorizada tem sua própria chave, gerada localmente, que nunca sai dela. Isso é seguro **mesmo com o repositório público**: AES-256 protege o conteúdo, só quem tem uma das chaves autorizadas consegue ler.

Pra autorizar uma máquina nova:
```bash
gpg --full-generate-key          # gera uma chave própria dessa máquina
gpg --export --armor <fingerprint> > minha-pub.asc
# leva o .asc até uma máquina já autorizada
git-crypt add-gpg-user --trusted <fingerprint>
```

## ⚙️ Funções

Definidas em `zsh/shared/functions/git.zsh`, disponíveis em qualquer shell:

| Função | O que faz |
|---|---|
| `git-cp "msg"` | commit + push do repositório atual |
| `git-cp-sync "msg"` | `git-cp` + sincroniza esse mesmo repo nas outras máquinas registradas |
| `git-sync [nome]` | puxa a versão mais recente nas outras máquinas (todos os repos, ou só um) |
| `git-status-all [nome]` | mesma varredura do `git-sync`, mas só mostra status, sem alterar nada |

Outros módulos automáticos, sem comando pra digitar: detecção de `ssh-agent` correto (evita conflito com gpg-agent), clipboard com fallback OSC52 quando não há sessão gráfica, e correção de comandos via `pay-respects`.

## 🗂️ Estrutura
```
jkyon-terminal/
    ├── zsh/ # shared/ (módulos comuns), machines/ (overrides por host), secrets/ (cifrado), plugins/ (submodules)
    ├── tmux/ # tmux.conf, conf.d/, plugins/tpm (submodule)
    ├── alacritty/ # alacritty.toml + tema
    ├── docs (screenshots e documentação)
    └── install.sh
```