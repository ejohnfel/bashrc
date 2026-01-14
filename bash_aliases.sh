#############################################
# [MARKER-ALIASES]
# Aliases
# Date 12/27/2020

alias rootme="sudo -s"
alias sudome="sudo -s"
alias ipaddr="ip addr"
alias pkgman="echo ${PACKAGEMANAGER}"
alias cls=clear
alias dils="sudo docker image ls | tail -n +2 | while read name tag image created just now size other; do printf \"\${name} \${tag} \${image}\n\"; done"
alias dcont="sudo docker container ls"
alias j="journalctl -xe"
alias sysc="systemctl status "
alias rcme="source ~/.bash_profile"
alias dexit="disown -a && exit"
alias noscreen="touch /tmp/${LOGNAME}.noscreen"
alias clearnoscreen="rm /tmp/${LOGNAME}.noscreen"

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
alias patchcloud="screen -c ~/.patchcloudrc"
alias patchhome="screen -c ~/.patchhomerc"
alias rmhost="ssh-keygen -R"
alias nfsclients="netstat | grep :nfs"

# SSH Stoof
alias sshprofiles="grep -E '^(h|H)ost' ~/.ssh/config | cut -d' ' -f 2 | less"
alias nokeyssh="ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no "
alias nokeyscp="scp -o PreferredAuthentications=password -o PubkeyAuthentication=no "
alias sshadd="ssh-add ~/.ssh/id_rsa ~/.ssh/id_rsa_vultr ~/.ssh/id_rsa_work ~/.ssh/id_github"
alias sshagent="ssh-agent bash"

# Custom Environmental Stuff
alias cur="cd ${CURRENT}"
