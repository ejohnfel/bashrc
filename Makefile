bashrcfiles = main.sh aliases.sh
updateosfiles = head.txt main.sh tail.txt
unattfiles = unattendedupdate.sh

all: bashrc updateos

bashrc: $(bashrcfiles)
	@cat $(bashrcfiles) > $@

updateos: $(updateosfiles)
	@cat $(updateosfiles) > $@

