CXX     ?= g++
VERSION ?= $(shell cat VERSION)
NAME    := $(shell cat NAME)
FILENAME := $(shell cd firmware ; ls *.gbl)
SHA256SUM := $(shell sha256sum firmware/*.gbl | awk {'print $$1'})
PACKAGE_JSON := "firmware/package.json"

archive: updater-app
	@cp package-sample.json firmware/package.json
	sed -i -e 's/VERSION/$(VERSION)/g' $(PACKAGE_JSON)
	sed -i -e 's/SHA256SUM/$(SHA256SUM)/g' $(PACKAGE_JSON)
	sed -i -e 's/FILENAME/$(FILENAME)/g' $(PACKAGE_JSON)
	cp firmware/* output/
	cp updater/resources/* output/
	cp enm_dev_reboot.py output/
	tar -C output/ -cJf OTA-update-$(NAME)-$(VERSION).tar.xz .

updater-app: updater/src/main.cpp
	mkdir -p output
	$(CXX) -std=c++11 updater/src/main.cpp -o output/updater-app

.PHONY : clean
clean :
		rm -rf output/*
		rm -f *.xz
