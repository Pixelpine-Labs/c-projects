# 000: Number stats (example)

Reference example for how a project folder is laid out. Copy this shape for
every ticket.

```
projects/000-example/
  README.md        how to build and run it, and any decisions you made
  src/main.c       all .c files in src/ are compiled together
  tests/
    mixed-numbers.in    input fed to the program
    mixed-numbers.out   exact output expected
    empty-input.code    expected exit code (only when it is not 0)
```

## Run it

```
make test P=projects/000-example
```

## Try it by hand

```
./build/000-example/app
```

Type some numbers, then press Ctrl+D on a new line to end the input.
