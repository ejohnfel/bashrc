#############################################
# [MARKER-ALIASES]
# Aliases
# Date 12/27/2020

alias rootme="sudo -s"
alias sudome="sudo -s"
alias ipaddr="ip addr"
alias cls=clear
alias ils="docker image ls | tail -n +2 | while read name tag image created just now size other; do printf \"\${name} \${tag} \${image}\n\"; done"
alias j="journalctl -xe"
alias sysc="systemctl status "
alias rcme="source ~/.bash_profile"
alias dexit="disown -a && exit"
# Only useful when 'hollywood' and/or mplayer is installed
alias mi="mplayer -vo caca /srv/storage/media/music/Soundtracks/mi.mp4"
alias os="cat /etc/os-release"

# Python VENV stuff
alias activate="source bin/activate"

# Custom Stoof
alias sshprofiles="grep -E '^host' ~/.ssh/config | cut -d' ' -f 2 | less"
