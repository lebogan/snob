-include Makefile.local # for optional local options

SHARDS ::= $(shell which shards)  # The shards command to use
CRYSTAL ::= $(shell which crystal) # The crystal command to use
INSTALL ::= $(shell which install) # The GNU install utility

SRC_SOURCES ::= $(shell find src -name '*.cr' 2>/dev/null)
LIB_SOURCES ::= $(shell find lib -name '*.cr' 2>/dev/null)
SPEC_SOURCES ::= $(shell find spec -name '*.cr' 2>/dev/null)
OBJECT_SOURCES ::= $(shell find src/c_src -name '*.o' 2>/dev/null)

NAME := snob## The target executable
CRFLAGS := --release --no-debug --warnings all## Production build flags
DEVFLAGS := --warnings all --error-on-warnings## Development build flags
RASPI64FLAGS := --cross-compile --target "aarch64-unknown-linux-gnu" --release## Rpi Ubuntu production build flags
RASPI4FLAGS := --cross-compile --target "armv7l-unknown-linux-gnueabihf" --release## Rpi production build flags
RASPI3FLAGS := --cross-compile --target "armv6k-unknown-linux-gnueabihf" --release## Rpi production build flags
CENTOSFLAGS := --cross-compile --target "x86_64-unknown-linux-gnu" --release## Centos production build flags
DEBIANFLAGS := --cross-compile --target "x86_64-pc-linux-gnu" --release## Centos production build flags
PREFIX := /usr/local## Install root directory
BINDIR := $(PREFIX)/bin## Install directory
MANDIR := $(PREFIX)/share/man## Man page directory
USER := $(shell id -ng)## User name

.PHONY: prod
prod: clean ## Build the optimized application binary
prod: $(SRC_SOURCES)
	@$(CRYSTAL) build src/$(NAME).cr -o bin/$(NAME) $(CRFLAGS)

.PHONY: dev
dev: clean ## Build development binary
	@mkdir -p bin
	$(CRYSTAL) build src/$(NAME).cr -o bin/$(NAME) $(DEVFLAGS)

.PHONY: raspi4
raspi4: ## RaspberryPi4 armv7l object file and compile script
raspi4: $(OBJECT_SOURCES) $(SRC_SOURCES)
	@$(CRYSTAL) build src/snob.cr -o bin/snob-rpi4 $(RASPI4FLAGS) | tee scripts/rpibuild4.sh
	@sed -i -e "s|-o bin/snob-rpi4|-o bin/snob|g" scripts/rpibuild4.sh

.PHONY: raspi64
raspi64: ## RaspberryPi4 aarch object file and compile script
raspi64: $(OBJECT_SOURCES) $(SRC_SOURCES)
	@$(CRYSTAL) build src/snob.cr -o bin/snob-aarch64 $(RASPI64FLAGS) | tee scripts/rpibuild64.sh
	@sed -i -e "s|-o bin/snob-aarch64|-o bin/snob|g" scripts/rpibuild64.sh

.PHONY: raspi3
raspi3: ## RaspberryPi3 armv6k object file and compile script
raspi3: $(OBJECT_SOURCES) $(SRC_SOURCES)
	@$(CRYSTAL) build src/snob.cr -o bin/snob-rpi3 $(RASPI3FLAGS) | tee scripts/rpibuild3.sh
	@sed -i -e "s|-o bin/snob-rpi3|-o bin/snob|g" scripts/rpibuild3.sh

.PHONY: centos
centos: ## Build the object file and compile script for rpm-based architectures
centos: $(OBJECT_SOURCES) $(SRC_SOURCES)
	@$(CRYSTAL) build src/$(NAME).cr -o bin/$(NAME)-centos $(CENTOSFLAGS) | tee scripts/centosbuild.sh
	@sed -i -e "s|-o bin/snob-centos|-o bin/snob|g" scripts/centosbuild.sh

.PHONY: debian
debian: ## Build the object file and compile script for deb-based architectures
debian: $(OBJECT_SOURCES) $(SRC_SOURCES)
	@$(CRYSTAL) build src/$(NAME).cr -o bin/$(NAME)-debian $(DEBIANFLAGS) | tee scripts/debianbuild.sh
	@sed -i -e "s|-o bin/snob-debian|-o bin/snob|g" scripts/debianbuild.sh

.PHONY: install
install: ## Install the application to /usr/local/bin
	$(INSTALL) -m 0755 -d "$(BINDIR)" "$(MANDIR)/man1" "$(MANDIR)/man5"
	$(INSTALL) -m 0755 bin/$(NAME) "$(BINDIR)"
	$(INSTALL) -m 0644 man/$(NAME).1 "$(MANDIR)/man1"
	$(INSTALL) -m 0644 man/$(NAME).yml.5 "$(MANDIR)/man5"

.PHONY: uninstall
uninstall: ## Remove the application
	rm -f "$(BINDIR)/$(NAME)"
	rm -f "$(MANDIR)/man1/$(NAME).1"
	rm -f "$(MANDIR)/man5/$(NAME).yml.5"

.PHONY: update
update: ## Update shards
	@$(SHARDS) update --ignore-crystal-version

.PHONY: test
test: ## Run test suite
test: $(SRC_SOURCES) $(SPEC_SOURCES)
	@$(CRYSTAL) spec

.PHONY: check
check: $(SRC_SOURCES)
check: ## Run code analysis checker
	@bin/ameba --all --gen-config

.PHONY: format
format: ## Apply source code formatting
format: $(SRC_SOURCES) $(SPEC_SOURCES)
	@$(CRYSTAL) tool format src spec

.PHONY: man
man: ## Generate manual pages
man: 
	@scripts/mkman.sh

.PHONY: docs
docs: ## Generate readme in epub and pdf formats
docs:
	@scripts/mkdocs.sh

.PHONY: clean
clean: ## Remove application binary
	rm -f bin/$(NAME)

.PHONY: help
help: ## Show this help
	@echo
	@printf '\033[34mtargets:\033[0m\n'
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) |\
		sort |\
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo
	@printf '\033[34moptional variables:\033[0m\n'
	@grep -hE '^[a-zA-Z_-]+ .*=.*?## .*$$' $(MAKEFILE_LIST) |\
		sort |\
		awk 'BEGIN {FS = " \\?=.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo
	@printf '\033[34mrecipes:\033[0m\n'
	@grep -hE '^##.*$$' $(MAKEFILE_LIST) |\
		awk 'BEGIN {FS = "## "}; /^## [a-zA-Z_-]/ {printf "  \033[36m%s\033[0m\n", $$2}; /^##  / {printf "  %s\n", $$2}'