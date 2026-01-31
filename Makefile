.PHONY: lint lint-scripts format check-format help

help:
	@echo "Available targets:"
	@echo "  lint          - Run shellcheck on all shell scripts"
	@echo "  format        - Format all shell scripts with shfmt (writes changes)"
	@echo "  check-format  - Check shell script formatting without modifying files"

lint: lint-scripts

lint-scripts:
	@echo "Running shellcheck..."
	shellcheck bin/* lib/* test/*.sh

format:
	@echo "Formatting shell scripts with shfmt..."
	shfmt --write --indent 0 --case-indent --binary-next-line bin/ lib/ test/

check-format:
	@echo "Checking shell script formatting..."
	shfmt --diff --indent 0 --case-indent --binary-next-line bin/ lib/ test/
