all: lint templates
.PHONY: env-check lint license-check templates clean test spm-build help

REPO_ROOT := $(PWD)
include tools/utils/common.mk

# Default ENV for setting up the repo
DEFAULT_ENV := dev

env-check:
	@$(ECHO_TITLE) "make env-check"
	./tools/env-check.sh

repo-setup:
	@:$(eval ENV ?= $(DEFAULT_ENV))
	@$(ECHO_TITLE) "make repo-setup ENV='$(ENV)'"
	./tools/repo-setup/repo-setup.sh --env "$(ENV)"

lint:
	@$(ECHO_TITLE) "make lint"
	# ./tools/lint/run-linter.sh
	# TODO: Re-enable linting once we have sources and tests

license-check:
	@$(ECHO_TITLE) "make license-check"
	./tools/license/check-license.sh

templates:
	@$(ECHO_TITLE) "make templates"
	./tools/xcode-templates/install-xcode-templates.sh

test:
	@$(ECHO_TITLE) "make test"
	# swift test
	# TODO: Re-enable testing once we have sources and tests

spm-build:
	@$(ECHO_TITLE) "make spm-build"
	swift build

clean:
	@$(ECHO_TITLE) "make clean"
	./tools/clean.sh --derived-data --pods --xcconfigs
