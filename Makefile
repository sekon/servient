PROJECT_NAME="servient"
PROJECT_VERSION=$(shell grep SERVIENT_VERSION_NUMBER= src/servient_util.sh  | cut -d "=" -f 2 | sed 's/"//g')


all:
	cd doc && $(MAKE) $@
	cd src && $(MAKE) $@

dist: mkdir_dist mk_dist_trbll 
	
mkdir_dist:
	mkdir -p $(PROJECT_NAME)_$(PROJECT_VERSION)
	cp src/*.sh $(PROJECT_NAME)_$(PROJECT_VERSION)

mk_dist_trbll:
	tar -cvzf $(PROJECT_NAME)_$(PROJECT_VERSION).tar.gz $(PROJECT_NAME)_$(PROJECT_VERSION)
	rm -rf $(PROJECT_NAME)_$(PROJECT_VERSION)

.Phony=all clean
