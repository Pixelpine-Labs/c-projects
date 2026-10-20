# Run from the repository root.
#   make test                              test every project
#   make test P=projects/002-unit-converter  test one project
#   make format                            fix formatting in place
#   make format-check                      what CI runs: fail if unformatted
#   make clean                             delete build output

SOURCES = $(shell find projects -name '*.[ch]' 2>/dev/null)

.PHONY: test format format-check clean

test:
	@bash scripts/run-tests.sh $(P)

# The empty check matters: clang-format with no file arguments reads
# standard input and waits forever.
format:
	@if [ -n "$(SOURCES)" ]; then clang-format -i $(SOURCES); fi

format-check:
	@if [ -n "$(SOURCES)" ]; then \
		clang-format --dry-run --Werror $(SOURCES) || { \
			echo "Formatting differs from .clang-format. Run 'make format', then commit."; \
			exit 1; }; \
	fi

clean:
	rm -rf build
