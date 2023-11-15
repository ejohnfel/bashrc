########################################################
# [AUTOMATED-INSERT-MARKER]
# Author Eric Johnfelt
# Date 11/15/2023
# Title: Main bashrc file
# Purpose: Is the ~/.bashrc file

BASHRCVERSION="202311151620"

# Source Aliases
[ -f ~/.bash_aliases ] && source ~/.bash_aliases

# Source Functions
[ -f ~/.bash_functions ] && source ~/.bash_functions

# Determine This Machines Location
DetermineLocation

# Setup SSH Agent
SSHSetup

# Fortune Cow Say
FortuneCow

# Sayings
RandomSaying

