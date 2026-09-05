#
#        Title:      highlight-overrides.zsh
#        Brief:      Customizações de estilo do zsh-syntax-highlighting.
#        Nota:       Precisa ser sourced DEPOIS do plugin (zsh/shared/plugins.zsh
#                    ou a linha equivalente em minimal.zsh) — ZSH_HIGHLIGHT_STYLES
#                    só existe como array associativo depois que o plugin
#                    é carregado.
#

# sudo (e demais "precommands": exec, nohup, etc.) em negrito, não underline
ZSH_HIGHLIGHT_STYLES[precommand]='fg=green,bold'
