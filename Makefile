bashrcfiles = main.sh
aliases= aliases.sh
updateosfiles = head.txt main.sh updos.sh tail.txt
services = services.list
misc = Makefile chgser hostinfo remove.sh update.sh
installfolder = /usr/local/bin

all: bashrc updateos

services: $(services)
	@cp $(services) ~/.services

bashrc: $(bashrcfiles)
	@cat $(bashrcfiles) > $@

updateos: $(updateosfiles)
	@cat $(updateosfiles) > $@

update: bashrc updateos automation services
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
	# @[ -e bashrc ] && rm basrhc || true
	@[ -e updateos ] && rm updateos || true
	@[ -e hostinfo.txt ] && rm hostinfo.txt || true
	@[ -e output.txt ] && rm output.txt || true
	@[ -f /tmp/.bashrc.bak ] && rm /tmp/.bashrc.bak || true
	@[ -f /tmp/.bash_profile.bak ] && rm /tmp/.bash_profile.bak || true

git: $(bashrcfiles) $(updateosfiles) $(services) $(aliases) $(misc)
	@./chgser
	@git add $?
	@git commit
	@git push

actions:
	@printf "==========n\Actions in this Makefile\n==========\n"
	@printf "actions\tThis display\n"
	@printf "all\tUpdate and deploy automation tools\n"
	@printf "services\tUpdate ~/.services list\n"
	@printf "bashrc\tBuild bashrc file\n"
	@printf "updateos\tBuild updateos file\n"
	@printf "update\tDo update deploy\n"
	@printf "automation\tDo Automation deploy\n"
	@printf "clean\tClean all intermediate files\n"
	@printf "git\tAdd, commit and push, you must add first\n"
