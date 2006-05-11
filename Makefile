NAME=$(shell basename $(shell pwd))
VERSION=$(shell darcs changes | grep '^  tagged ' | sed 's/  tagged //' | head -1)
BUILD=$(shell date +%Y%m%d%H)
FILE=$(NAME)-$(VERSION).$(BUILD).xpi
URL=http://repo.hyperstruct.net/mozrepl/$(FILE)

dist: $(FILE)

$(FILE):
	rm -rf dist
	mkdir dist dist/chrome
	cd chrome && zip -y -r ../dist/chrome/$(NAME).jar .
	sed -e 's|chrome/|jar:chrome/$(NAME).jar!/|g' chrome.manifest >dist/chrome.manifest
	sed -e 's|<em:version></em:version>|<em:version>$(VERSION).$(BUILD)</em:version>|' \
		install.rdf.template >dist/install.rdf
	sed -e 's|<version></version>|<version>$(VERSION).$(BUILD)</version>|g' \
		-e 's|<updateLink></updateLink>|<updateLink>$(URL)</updateLink>|g' \
		update.rdf.template > update.rdf
	cp -a defaults dist
	cd dist && zip -r ../$(FILE) *
	rm -rf dist

upload: dist
	scp $(FILE) update.rdf cube.hyperstruct.net:/var/www/repo.hyperstruct.net/public/mozrepl/

clean:
	rm -rf dist *.xpi update.rdf

.PHONY: dist clean upload