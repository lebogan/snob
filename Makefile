-include Makefile.local # for optional local options

SHARDS ::= shards   # The shards command to use
CRYSTAL ::= crystal # The crystal command to use
INSTALL ::= /usr/bin/install # The GNU install utility


SRC_SOURCES ::= $(shell find src -name '*.cr' 2>/dev/null)
LIB_SOURCES ::= $(shell find lib -name '*.cr' 2>/dev/null)
SPEC_SOURCES ::= $(shell find spec -name '*.cr' 2>/dev/null)
OBJECT_SOURCES ::= $(shell find src/c_src -name '*.o' 2>/dev/null)

NAME := snob## The target executable
CRFLAGS := --release --warnings all## Production build flags
DEVFLAGS := --warnings all --error-on-warnings## Development build flags
RASPIFLAGS := --cross-compile --target "armv6k-unknown-linux-gnueabihf" --release## Rpi production build flags
PREFIX := /usr/local## Install root directory
BINDIR := $(PREFIX)/bin## Install directory
MANDIR := $(PREFIX)/share/man## Man page directory
USER := $(shell id -ng)## User name

.PHONY: prod
prod: ## Build the optimized application binary
prod: $(SRC_SOURCES) #lib
	$(CRYSTAL) build src/$(NAME).cr -o bin/$(NAME) $(CRFLAGS)

.PHONY: dev
dev: clean ## Build development binary
	@mkdir -p bin
	$(CRYSTAL) build src/$(NAME).cr -o bin/$(NAME) $(DEVFLAGS)

.PHONY: raspi
raspi: ## Build the object file and compile script for RaspberryPi4
raspi: $(OBJECT_SOURCES) $(SRC_SOURCES)
	$(CRYSTAL) build src/snob.cr -o bin/snob $(RASPIFLAGS) | tee rpibuild.sh

.PHONY: install
install: ## Install the application to /usr/local/bin
	$(INSTALL) -m 0755 -d "$(BINDIR)" "$(MANDIR)/man1" "$(MANDIR)/man5"
	$(INSTALL) -m 0755 bin/$(NAME) "$(BINDIR)"
	$(INSTALL) -m 0644 man/$(NAME).1 "$(MANDIR)/man1"
	$(INSTALL) -m 0644 man/$(NAME).5 "$(MANDIR)/man5"

.PHONY: uninstall
uninstall: ## Remove the application
	rm -f "$(BINDIR)/$(NAME)"
	rm -f "$(MANDIR)/man1/$(NAME).1"
	rm -f "$(MANDIR)/man5/$(NAME).5"

.PHONY: update
update: shard.lock ## Update shards

.PHONY: test
test: ## Run test suite
test: $(SRC_SOURCES) $(SPEC_SOURCES)
	$(CRYSTAL) spec

.PHONY: check
check: $(SRC_SOURCES)
check: ## Run code analysis checker
	bin/ameba --all

.PHONY: format
format: ## Apply source code formatting
format: $(SRC_SOURCES) $(SPEC_SOURCES)
	$(CRYSTAL) tool format src spec

docs: ## Generate API docs
docs: $(SRC_SOURCES) lib
	$(CRYSTAL) docs -o docs

lib: shard.lock
	$(SHARDS) install

shard.lock: shard.yml
	$(SHARDS) update

.PHONY: clean
clean: ## Remove application binary
	rm -f bin/$(NAME)

.PHONY: help
help: ## Show this help
	@echo
	@printf '\033[34mtargets:\033[0m\n'
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) |\
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