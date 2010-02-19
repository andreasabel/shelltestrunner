# shelltestrunner project makefile

build:
	ghc --make -threaded -Wall shelltestrunner.hs

test: build
	./shelltestrunner ./shelltestrunner tests/*.test -j8

TARBALL:=$(shell cabal sdist | tail -1 | cut -d' ' -f4)
VERSION:=$(shell echo $(TARBALL) | cut -d- -f2 | cut -d. -f1-3)

showversion:
	@echo $(VERSION)

tagrepo:
	@(darcs show tags | grep -q "^$(VERSION)$$") && echo tag $(VERSION) already present || darcs tag $(VERSION)

push:
	darcs push -a joyful.com:/repos/shelltestrunner

release: test tagrepo push
	cabal sdist
	(cabal upload $(TARBALL) --check | grep '^OK$$') \
		&& cabal upload $(TARBALL) \
		|| (cabal upload $(TARBALL) --check -v3; false)

docs haddock:
	cabal configure && cabal haddock --executables

tag: emacstags

emacstags:
	rm -f TAGS; hasktags -e *hs *.cabal

clean:
	rm -f `find . -name "*.o" -o -name "*.hi" -o -name "*~" -o -name "darcs-amend-record*" -o -name "*-darcs-backup*"`

Clean: clean
	rm -f TAGS shelltestrunner
