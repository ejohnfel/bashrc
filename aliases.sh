# Aliases

alias rootme="sudo -s"
alias cls=clear
alias ils="docker image ls | tail -n +2 | while read name tag image created just now size other; do printf \"\${name} \${tag} \${image}\n\"; done"
alias j="journalctl -xe"
alias leases="[ -f /var/lib/dhcp/dhcpd.leases ] && less /var/lib/dhcp/dhcpd.leases || printf 'No lease file on this host\n'"
