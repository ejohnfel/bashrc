########################################################
# [AUTOMATED-INSERT-MARKER]
# Author Eric Johnfelt
# Date 11/15/2023
# Title Environment variable snippets
# Environment Variables for RC files

MYIP=$(ip a | grep -E "^\s+inet\s" | grep -v "127.0.0.1" | tr -s " " | head -n 1 | cut -d" " -f3 | cut -d"/" -f 1)

declare -a UPDCMDS

# Git stuff
MYGITREP=ejohnfel
BASHRCGIT="https://github.com/ejohnfel/bashrc"

ISNAT=0
INTERNIP="${MYIP}"
EXTERNIP="UNKNOWN"

FIXCHECK=""
PREFIX=""

LOCATION="internal"
MYDOMAIN="digitalwicky.biz"
SAYINGS="/srv/storage/data/waiting.txt"
BSHDEBUG=0
MANPAGER='less -s -X -F'
export MANPAGER

HISTTIMEFORMAT='%F %T '

PATH="${PATH}:~/bin"

# Locations of things of interest
export SAYINGS="/srv/storage/data/waiting.txt"
export PROMNT="/srv/storage/projects"
export STOMNT="/srv/storage"
export DATMNT="/srv/storage/data"
export SCRMNT="/srv/storage/projects/scripts"

# Flags & Script Runtime Placeholders
export BSHDEBUG
export TARGET=""

# Shell Environment Enhancements
export MANPAGER='less -s -X -F'
export CDPATH=.:/srv:/srv/storage:/srv/storage/projects:/srv/storage/projects/containers:/srv/storage/projects/scripts:/home/ejohnfelt

