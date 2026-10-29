# Builder — headless por natureza (só acesso via SSH, sem GUI).
typeset -g JKYON_HEADLESS=true

# Incubadora de binpkgs (nspawn + binds + /run/lock):
#   incubadora viamar-pc                      -> shell
#   incubadora viamar-pc emerge -uDN @world   -> comando
alias incubadora='sudo /home/jkyon/ShellScript/Builder/Scripts/incubadora/incubadora.sh'
