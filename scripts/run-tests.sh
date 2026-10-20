#!/usr/bin/env bash
# Builds each project with the team's strict compiler flags and runs every
# test case in its tests/ folder under valgrind.
#
# Usage:
#   scripts/run-tests.sh                      test every project
#   scripts/run-tests.sh projects/002-name    test one project
#
# A test case is a pair of files in <project>/tests/:
#   <case>.in    fed to the program on standard input
#   <case>.out   the exact standard output expected
# and optionally:
#   <case>.args  command-line arguments, on one line
#   <case>.code  expected exit code (0 when the file is missing)
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cc="${CC:-gcc}"
cflags=(-std=c11 -Wall -Wextra -Werror -pedantic -g -O0)
# 5 seconds is far more than any ticket needs; a program still running then
# is almost always stuck in a loop waiting for input that never comes.
time_limit=5
# Exit code valgrind uses to report a memory error. Chosen high so it does
# not collide with the small exit codes the tickets ask for.
memory_error_code=99

for tool in "$cc" valgrind timeout diff; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "error: '$tool' is not installed. Run Ticket #1, Part C, then retry." >&2
    exit 2
  fi
done

projects=()
if [ "$#" -gt 0 ]; then
  for arg in "$@"; do
    projects+=("${arg%/}")
  done
else
  shopt -s nullglob
  projects=("$root"/projects/*/)
  shopt -u nullglob
fi

# An empty repo is a normal state on day one, not a failure.
if [ "${#projects[@]}" -eq 0 ]; then
  echo "No projects yet. Nothing to test."
  exit 0
fi

failed=0
passed=0

fail() {
  echo "  FAIL  $1"
  failed=$((failed + 1))
}

for project in "${projects[@]}"; do
  project="${project%/}"
  name="$(basename "$project")"
  echo "== $name"

  if [ ! -d "$project" ]; then
    fail "folder '$project' does not exist"
    continue
  fi

  shopt -s nullglob
  sources=("$project"/src/*.c)
  cases=("$project"/tests/*.in)
  shopt -u nullglob

  if [ "${#sources[@]}" -eq 0 ]; then
    fail "no .c files in $name/src/"
    continue
  fi
  # A project without tests cannot prove it works, so it does not pass.
  if [ "${#cases[@]}" -eq 0 ]; then
    fail "no test cases (*.in files) in $name/tests/"
    continue
  fi

  out_dir="$root/build/$name"
  mkdir -p "$out_dir"
  app="$out_dir/app"

  if ! "$cc" "${cflags[@]}" "${sources[@]}" -o "$app" -lm; then
    fail "$name does not compile (see the compiler messages above)"
    continue
  fi

  for input in "${cases[@]}"; do
    base="${input%.in}"
    case_name="$(basename "$base")"
    expected="$base.out"
    actual="$out_dir/$case_name.actual"
    errors="$out_dir/$case_name.stderr"

    if [ ! -f "$expected" ]; then
      fail "$case_name: missing $case_name.out next to $case_name.in"
      continue
    fi

    args=()
    if [ -f "$base.args" ]; then
      read -r -a args <"$base.args" || true
    fi
    expected_code=0
    if [ -f "$base.code" ]; then
      expected_code="$(tr -d '[:space:]' <"$base.code")"
    fi

    set +e
    timeout "$time_limit" valgrind -q --leak-check=full \
      --errors-for-leak-kinds=definite \
      --error-exitcode="$memory_error_code" \
      "$app" "${args[@]}" <"$input" >"$actual" 2>"$errors"
    code=$?
    set -e

    if [ "$code" -eq 124 ]; then
      fail "$case_name: still running after ${time_limit}s (infinite loop?)"
      continue
    fi
    if [ "$code" -eq "$memory_error_code" ]; then
      fail "$case_name: valgrind found a memory error"
      sed 's/^/        /' "$errors"
      continue
    fi
    if [ "$code" -ne "$expected_code" ]; then
      fail "$case_name: exit code $code, expected $expected_code"
      continue
    fi
    if ! diff -u --label expected --label actual "$expected" "$actual" \
      >"$out_dir/$case_name.diff"; then
      # Windows line endings make two lines look identical in the diff, so
      # name that cause explicitly instead of showing a confusing diff.
      if diff -q --strip-trailing-cr "$expected" "$actual" >/dev/null; then
        fail "$case_name: only line endings differ. Save $case_name.out with LF (Linux) line endings, not CRLF."
        continue
      fi
      fail "$case_name: output differs ('-' expected, '+' your program)"
      head -n 40 "$out_dir/$case_name.diff" | sed 's/^/        /'
      continue
    fi

    echo "  pass  $case_name"
    passed=$((passed + 1))
  done
done

echo
echo "$passed passed, $failed failed"
[ "$failed" -eq 0 ]
