CXX     ?= g++
VERSION := $(shell cat package.json | jq -r '.version')
NAME    := $(shell cat package.json | jq -r '.application')


archive:
	mkdir -p output
	cp package.json output/
	cp packages/* output/
	cp src/* output/
	tar -cJf OTA-update-$(NAME)-$(VERSION).tar.xz  -C output/ .


.PHONY : clean
clean :
		rm -rf output/*
		rm -f *.xz
