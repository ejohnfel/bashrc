bashrcfiles = main.sh aliases.sh
updateosfiles = head.txt main.sh tail.txt
installfolder = /usr/local/bin

all: bashrc updateos

bashrc: $(bashrcfiles)
	@cat $(bashrcfiles) > $@

updateos: $(updateosfiles)
	@cat $(updateosfiles) > $@

update: bashrc updateos automation
	@chmod ugo+rx update.sh
	@./update.sh

automation: updateos
ifeq "$(LOGNAME)" "root"
	@cp updateos $(unattfiles) $(installfolder)
	@chmod ugo=rx $(installfolder)/updateos
else
	@echo "You must have SUDO privileges to complete this part of the install"
	@sudo cp updateos $(unattfiles) $(installfolder)
	@sudo chmod ugo=rx,o-w $(installfolder)/updateos
endif

clean:
	@echo "Cleaning created files"
	@rm bashrc updateos
