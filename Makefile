.POSIX:

CRYSTAL = crystal
CRFLAGS = --release --warnings all --error-on-warnings
SOURCES = src/*.cr

NAME = snob
DESTDIR =
PREFIX = /usr/local
BINDIR = $(DESTDIR)$(PREFIX)/bin
MANDIR = $(DESTDIR)$(PREFIX)/share/man
INSTALL = /usr/bin/install

all: bin/$(NAME)

clean: phony
	rm -f bin/$(NAME)

bin/$(NAME): $(SOURCES)
	@mkdir -p bin
	$(CRYSTAL) build src/$(NAME).cr -o bin/$(NAME) $(CRFLAGS)

install: bin/$(NAME) phony
	$(INSTALL) -m 0755 -d "$(BINDIR)" "$(MANDIR)/man1" "$(MANDIR)/man5"
	$(INSTALL) -m 0755 bin/$(NAME) "$(BINDIR)"
	$(INSTALL) -m 0644 man/$(NAME).1 "$(MANDIR)/man1"
	$(INSTALL) -m 0644 man/$(NAME).5 "$(MANDIR)/man5"

uninstall: phony
	rm -f "$(BINDIR)/$(NAME)"
	rm -f "$(MANDIR)/man1/$(NAME).1"
	rm -f "$(MANDIR)/man5/$(NAME).5"

# rspec and ameba tests
test: spec check

spec: phony
	@bin/$(NAME) --generate test_$(NAME)
	$(CRYSTAL) spec spec/$(NAME)_spec.cr

check: phony
	./bin/ameba --all

help: phony
	@echo
	@printf '\033[34mall: [default]\033[0m\n'
	@echo
	@printf '\033[34minstall: Requires sudo\033[0m\n'
	@echo
	@printf '\033[34muninstall: Requires sudo\033[0m\n'
	@echo
	@printf '\033[34mclean: Remove compiled binary\033[0m\n'
	@echo
	@printf '\033[34mtest: Spec and ameba tests\033[0m\n'

phony:
