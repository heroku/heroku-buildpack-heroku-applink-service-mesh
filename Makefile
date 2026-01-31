.PHONY: lint lint-scripts format check-format help

help:
	@echo "Available targets:"
	@echo "  lint          - Run shellcheck on all shell scripts"
	@echo "  format        - Format all shell scripts with shfmt (writes changes)"
	@echo "  check-format  - Check shell script formatting without modifying files"

lint: lint-scripts

lint-scripts:
	@echo "Running shellcheck..."
	@git ls-files -z --cached --others --exclude-standard 'bin/*' 'lib/*' 'test/*.sh' | xargs -0 shellcheck --check-sourced --color=always

format:
	@echo "Formatting shell scripts with shfmt..."
	@shfmt --write .

check-format:
	@echo "Checking shell script formatting..."
	@shfmt --diff .
