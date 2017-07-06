bashrcfiles = main.sh aliases.sh
updateosfiles = head.txt main.sh tail.txt
unattfiles = unattendedupdate.sh
installfolder = /usr/bin/local

all: bashrc updateos

bashrc: $(bashrcfiles)
	@cat $(bashrcfiles) > $@

updateos: $(updateosfiles)
	@cat $(updateosfiles) > $@

update: bashrc
	@chmod ugo+rx update.sh
	@./update.sh

automation: updateos
ifeq "$(LOGNAME)" "root"
	@cp updateos $(unattfiles) $(installfolder)
	@chmod ug=rx $(installfolder)/updateos $(installfolder)/$(unattfiles)
else
	@echo -e "You must be root to install"
endif

clean:
	@echo -e "Cleaning created files"
	@rm bashrc updateos
