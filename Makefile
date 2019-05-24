bashrcfiles = main.sh aliases.sh
updateosfiles = head.txt main.sh updos.sh tail.txt
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
	@cp hostinfo $(installfolder)
	@chmod ugo=rx $(installfolder)/hostinfo
else
	@sudo cp updateos $(unattfiles) $(installfolder)
	@sudo chmod ugo=rx,o-w $(installfolder)/updateos
	@sudo cp hostinfo $(installfolder)
	@sudo chmod ugo=rx $(installfolder)/hostinfo
endif

clean:
	@echo "Cleaning created files"
	@[ -e bashrc ] && rm basrhc || true
	@[ -e updateos ] && rm updateos || true
	@[ -e hostinfo.txt ] && rm hostinfo.txt || true
	@[ -e output.txt ] && rm output.txt || true
