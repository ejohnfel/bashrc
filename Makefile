bashrcfiles = main.sh aliases.sh
updateosfiles = head.txt main.sh tail.txt
installfolder = /usr/local/bin

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
	@chmod ug=rx $(installfolder)/updateos
else
	@echo "You must be root to install"
endif

clean:
	@echo "Cleaning created files"
	@rm bashrc updateos
