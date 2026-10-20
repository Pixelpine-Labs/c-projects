# c-projects

Pixelpine Labs C engineering repository. Every project here starts as a
ticket (a GitHub Issue) and arrives through a reviewed pull request.

## Layout

```
projects/NNN-short-name/   one folder per ticket, NNN = the issue number
  src/                     the code (all .c files compile together)
  tests/                   test cases: .in input, .out expected output
scripts/run-tests.sh       builds and tests projects (used by make and CI)
.github/                   CI, pull request template, code owners
```

[projects/000-example](projects/000-example) shows the layout in a real
project.

## Everyday commands

Run these from the repository root, inside Ubuntu (WSL):

| Command | What it does |
|---|---|
| `make test` | Build and test every project |
| `make test P=projects/002-unit-converter` | Build and test one project |
| `make format` | Fix the code formatting |
| `make format-check` | Check formatting the way CI does |
| `make clean` | Delete build output |

## How work gets done here

Read [CONTRIBUTING.md](CONTRIBUTING.md) before you start your first ticket.
It covers the rules, the branch and pull request workflow, and how review
works.
