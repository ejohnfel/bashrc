#############################################
# [MARKER-ALIASES]
# Aliases
# Date 12/27/2020

alias rootme="sudo -s"
alias sudome="sudo -s"
alias ipaddr="ip addr"
alias pkgman="echo ${PACKAGEMANAGER}"
alias cls=clear
alias ils="docker image ls | tail -n +2 | while read name tag image created just now size other; do printf \"\${name} \${tag} \${image}\n\"; done"
alias j="journalctl -xe"
alias sysc="systemctl status "
alias rcme="source ~/.bash_profile"
alias dexit="disown -a && exit"
# Only useful when 'hollywood' and/or mplayer is installed
alias mi="mplayer -vo caca /srv/storage/media/music/Soundtracks/mi.mp4"
alias os="cat /etc/os-release"
alias sane="stty sane"

# Python VENV stuff
alias activate="source bin/activate"

# Ansible Stoof
alias ap="ansible-playbook"
alias kf="ansible-playbook -i inventory.txt keyfacts.xml -l"

# Custom Stoof
alias sshprofiles="grep -E '^(h|H)ost' ~/.ssh/config | cut -d' ' -f 2 | less"
alias patchcloud="screen -c ~/.patchcloudrc"
alias patchhome="screen -c ~/.patchhomerc"
alias rmhost="ssh-keygen -R"

# Emergency/Utilitarian Stoof
alias nokeyssh="ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no "
alias nokeyscp="scp -o PreferredAuthentications=password -o PubkeyAuthentication=no "
