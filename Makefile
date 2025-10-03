all: lint templates
.PHONY: lint templates clean test spm-build help

REPO_ROOT := $(PWD)
include tools/utils/common.mk

# Default ENV for setting up the repo
DEFAULT_ENV := dev

lint:
	@$(ECHO_TITLE) "make lint"
	./tools/lint/run-linter.sh

templates:
	@$(ECHO_TITLE) "make templates"
	./tools/xcode-templates/install-xcode-templates.sh

test:
	@$(ECHO_TITLE) "make test"
	swift test

spm-build:
	@$(ECHO_TITLE) "make spm-build"
	swift build

clean:
	@$(ECHO_TITLE) "make clean"
	swift package clean
	rm -rf .build
