#
#        Title:      alias.zsh
#        Brief:      My custom aliases for the terminal
#        Path:       /home/jkyon/.jkyon-terminal/zsh/shared/alias.zsh
#        Author:     John Kennedy a.k.a. jKyon
#        Created:    2026-02-23
#        Updated:    2026-08-19
#        Notes:      All the aliases I use in the terminal, organized alphabetically by the command they alias.
#                    Some of these aliases are just for fun, while others are meant to improve my workflow and productivity.
#                    Feel free to use any of these aliases or modify them to suit your needs!
#
# A
#
# B
alias bulk-ocr='/home/jkyon/ShellScript/Tools/bulk-ocr/bulk-ocr.sh'
#
# C
alias claudio='cd ~/.jkyon-ai-context && claude'
alias cp='cp -v'
#
# D
alias dead-process-watcher='watch19 '\''ps -eo ppid,pid,stat,comm | grep " D" && ps -eo ppid,pid,stat,comm | grep " Z"'\'
#
# E
alias ealias='nvim /home/jkyon/.jkyon-terminal/zsh/shared/alias.zsh && rzsh'
alias efstab='sudo -e /etc/fstab'
alias emake='/home/jkyon/ShellScript/Tools/imake/emake/emake.sh'
#
# F
alias ffetch='env -u ZELLIJ sh /home/jkyon/ShellScript/Tools/ffetch/ffetch.sh'
#
# G
alias grep='grep --colour=auto'
#
# H
# alias helptty='sudo fbset -xres 3440 -yres 1440 && sh /home/jkyon/ShellScript/Tools/tmux-quickstart.sh'
#
# I
alias iotop='sudo iotop -aoP'
#
# J
#
#
# K
#
# L
alias ls='lsd'
alias lsblk-mine='lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT'
alias lsl='lsd -l'
alias lsla='lsd -la'
alias lsusb='echo "Use cyme instead: cyme --tree"'
#
# M
alias man='LANG=pt_BR.UTF-8 man'
alias me-avise='sh /home/jkyon/ShellScript/Tools/avisoNoTerminal.sh'
alias mv='mv -v'
#
# N
alias niri-status-services="/home/jkyon/ShellScript/niri/Tools/niri-status-services/niri-status-services.sh"
#
# O
# Mesmo provedor hoje em casa e no trabalho (7km de distância) — mantidos
# separados de propósito, caso um dia um dos dois mude de provedor.
alias ookla-home='speedtest --server-id=53390'
alias ookla-work='speedtest --server-id=53390'
#
# P
alias portage-panel='zellij --layout portage-panel'
#
# Q
#
# R
alias reboot='systemctl reboot'
alias rg='rg --color=auto'
alias rzsh='source /home/jkyon/.zshrc && sleep 1'
#
# S
alias scan-to-ai='/home/jkyon/ShellScript/Tools/scan-to-ai/scan-to-ai.sh'
alias sensors-watch='nice --adjustment=19 watch --interval 3 --differences sensors'
alias smart-cleanup='/home/jkyon/.local/bin/smart-cache-cleanup.sh'
alias ssh-test-connection='sh /home/jkyon/ShellScript/Tools/ssh-test-connection/ssh-test-connection.sh'
#
# T
#
# U
alias unlock-sudo='echo "Use root password" && su -c "faillock --user jkyon --reset"'
alias update-all-arch='pssh -H "viamar-pc crisnote builder" -l jkyon -i "bash /home/jkyon/ShellScript/Tools/update-distro/updateDistro.sh"'
alias update-distro='sh /home/jkyon/ShellScript/Tools/update-distro/updateDistro.sh'
alias upgrade-all-arch='pssh -H "viamar-pc crisnote builder" -l jkyon -i "bash /home/jkyon/ShellScript/Viamar-PC/upgradeParu.sh"'
alias upgrade-distro='sh /home/jkyon/ShellScript/Tools/upgrade-distro/upgradeDistro.sh'
# TODO: hoje só funciona na TheseusMachine — plano é unificar num script que
# detecta a máquina e roda a compilação certa pra cada hardware, mantendo
# acompanhamento interativo. Fica em aberto de propósito, como lembrete.
alias upgrade-kernel='sh /home/jkyon/ShellScript/TheseusMachine/tools/upgrade-kernel/upgrade-kernel.sh'
#
# V
alias valias='bat /home/jkyon/.jkyon-terminal/zsh/shared/alias.zsh' # ampliar para mostrar da máquina vigente
alias vfstab='bat /etc/fstab'
alias vmake='/home/jkyon/ShellScript/Tools/imake/vmake/vmake.sh'
#
# W
alias wake-builder='ssh viamar-pc "bash /home/jkyon/ShellScript/Viamar-PC/Scripts/wake-builder/wake-builder.sh"'
alias wake-theseusmachine='ssh crisnote "bash /home/jkyon/ShellScript/CrisNote/tools/wake-theseusmachine/wake-theseusmachine.sh"'
alias wake-viamar='ssh builder "bash /home/jkyon/ShellScript/Viamar-PC/Scripts/wake-viamar/wake-viamar.sh"'
alias watch-disks='nice -n 19 watch -n 1 --color --differences "echo && df -h /efi /boot / /home /mnt/cache"'
alias watch19='sh /home/jkyon/ShellScript/Tools/watch19.sh'
#
# X
#
# Y
#
# Z
#