#
#        Title:      theseusmachine.zsh
#        Brief:
#        Path:       /home/jkyon/.jkyon-terminal/zsh/machines/theseusmachine.zsh
#        Author:     John Kennedy a.k.a. jKyon
#        Created:    2026-08-07
#        Updated:    2026-08-18
#        Notes:
#


# Aliases específicos (Gentoo/Portage — não fazem sentido fora daqui)

#
#  A B C
#
#  D
alias distcc-portage-watch='nice --adjustment=19 env DISTCC_DIR=/var/tmp/portage/.distcc distccmon-text 1'
#
#  E F
#
#  G
alias genlop-watch='nice --adjustment=19 watch --color --interval 1 genlop -ci'
#
#  H I J
#
#  K
#
#  L M N O
#
#  P
alias portage-panel='zellij --layout portage-panel'
alias portage-sync='update-mirrorselect && sudo emerge --verbose --sync && update-distro'
alias portage-unused-ranker='sh /home/jkyon/ShellScript/TheseusMachine/portage-tools/portage-unused-ranker/portage-unused-ranker.sh'
#
#  Q
#
#  R
alias radeontop='radeontop --color --transparency'
#
#  S
# alias satisfactory-server='sh /home/jkyon/ShellScript/Games/satisfactory-server-update.sh'
#
#  T
alias theseusmachine-kernel-upgrade-panel='zellij --layout theseusmachine-kernel-upgrade-panel'
#
#  U
alias update-mirrorselect='sh /home/jkyon/ShellScript/TheseusMachine/systemd/PortageSync/systemd-mirrorselect-update.sh'
#
#  V
#
#  W
# alias wacom-set-stylus='xsetwacom set "Wacom Intuos S Pen stylus" MapToOutput DisplayPort-0' # Funciona no niri?
#
#  X Y Z