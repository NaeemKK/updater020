CXX     = g++
FILENAME := $(shell cd firmware ; ls *.ebl)
SHA256SUM := $(shell sha256sum firmware/*.ebl | awk {'print $$1'})
PACKAGE_JSON := "firmware/package.json"


archive: updater-app
	sed -i -e 's/SHA256SUM/$(SHA256SUM)/g' $(PACKAGE_JSON)
	sed -i -e 's/FILENAME/$(FILENAME)/g' $(PACKAGE_JSON)
	cp firmware/* output/
	cp updater/resources/* output/
	tar -C output/ -cJf OTA-update.tar.xz .

updater-app: updater/src/main.cpp
	mkdir -p output
	$(CXX) -std=c++11 updater/src/main.cpp -o output/updater-app

.PHONY : clean
clean :
		rm -rf output/*
		rm -f *.xz
