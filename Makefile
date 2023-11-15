installfolder = /usr/local/bin

all: bashrc updateos

# Assemble RC Ecosystem
bash_functions: bash_functions.sh
	@cat $< > ~/.$@

bash_aliases: bash_aliases.sh
	@cat $< > ~/.$@

bash_envs: bash_envs.sh
	@cat $< > ~/.$@

# Assemble updateos
updateos: head.sh bash_functions.sh updos.sh tail.sh
	@sudo cat $< > $@

update: bash_envs bash_aliases bash_functions automation
	@chmod ugo+rx update.sh
	@./update.sh bashrc.sh ~/.bashrc
	@./update.sh bash_profile.sh ~/.bash_profile

automation: updateos
ifeq "$(LOGNAME)" "root"
	@cp updateos $(installfolder)
	@chmod ugo=rx $(installfolder)/updateos
	@cp hostinfo $(installfolder)
	@chmod ugo=rx $(installfolder)/hostinfo
else
	@printf "==[ Attempting sudo for install ]==\n"
	@sudo cp updateos $(unattfiles) $(installfolder)
	@sudo chmod ugo=rx,o-w $(installfolder)/updateos
	@sudo cp hostinfo $(installfolder)
	@sudo chmod ugo=rx $(installfolder)/hostinfo
endif

clean:
	@echo "Cleaning created files"
	@[ -e bashrc ] && rm bashrc || true
	@[ -e updateos ] && rm updateos || true
	@[ -e hostinfo.txt ] && rm hostinfo.txt || true
	@[ -e output.txt ] && rm output.txt || true
	@[ -f /tmp/.bashrc.bak ] && rm /tmp/.bashrc.bak || true
	@[ -f /tmp/.bash_profile.bak ] && rm /tmp/.bash_profile.bak || true

git: $(bashrcfiles) $(updateosfiles) $(misc)
	@./chgser
	@git add $?
	@git commit
	@git push

actions:
	@printf "==========\nActions in this Makefile\n==========\n"
	@printf "actions\t\tThis display\n"
	@printf "all\t\tUpdate and deploy automation tools\n"
	@printf "services\tUpdate ~/.services list\n"
	@printf "bashrc\t\tBuild bashrc file\n"
	@printf "updateos\tBuild updateos file\n"
	@printf "update\t\tDo update deploy\n"
	@printf "automation\tDo Automation deploy (reqs root, will attempt to sudo)\n"
	@printf "clean\t\tClean all intermediate files\n"
	@printf "git\t\tAdd, commit and push, you must add first\n"
