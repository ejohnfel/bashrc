#############################################
# [MARKER-ALIASES]
# Aliases

alias rootme="sudo -s"
alias cls=clear
alias ils="docker image ls | tail -n +2 | while read name tag image created just now size other; do printf \"\${name} \${tag} \${image}\n\"; done"
alias j="journalctl -xe"
alias sysc="systemctl status "
alias rcme="source ~/.bash_profile"
# Only useful when 'hollywood' and/or mplayer is installed
alias mi="mplayer -vo caca /srv/storage/media/music/Soundtracks/mi.mp4"
alias os="cat /etc/os-release"
