# s21check
THIS PROJECT IN BETA
School 21 C project checker: `clang-format`, `s21lint`, `cppcheck`, and Valgrind in one command.

## Installation

**macOS / Linux:**

```sh
later
```

If `s21check` is not found after installation, add the local binary directory to your shell config:

```sh
later
```

For Zsh, add it to `~/.zshrc`. For Bash, add it to `~/.bashrc` or `~/.bash_profile`.

## Usage

Run `s21check` from the project root, where `./src` is located, or directly from the `src/` directory:

```sh
s21check                         # format + lint
s21check all                     # format + cppcheck + lint
s21check format                  # clang-format only
s21check lint                    # s21lint only
s21check static                  # cppcheck only
s21check valgrind <test-binary>  # Valgrind inside a Docker/Podman container
s21check doctor                  # check required dependencies
s21check --debug <command>       # run any command with verbose step output
```

## Commands

### `s21check`

Runs `clang-format` and `s21lint`.

```text
➜ checking clang-format
➜ project dir: /path/to/project/src
✓ clang-format passed
➜ running s21lint
✓ s21lint passed
✓ all checks passed
```

### `s21check all`

Runs `clang-format`, `cppcheck`, and `s21lint`.

### `s21check valgrind <test-binary>`

Runs `make test` and then runs the given test binary under Valgrind inside a Debian container. Results are written to `valgrind.log` in the detected project directory.

```sh
s21check valgrind tests/binaries/s21_decimal_tests
```

```text
➜ using existing container image: s21check-valgrind
➜ running valgrind in container
➜ project dir: /path/to/project/src
➜ test binary: /path/to/project/src/ur_test_binary
➜ valgrind log: /path/to/project/src/valgrind.log
✓ valgrind passed
```

The container image is built once and reused. Both Docker and Podman are supported.

### `s21check doctor`

Checks whether the required tools are installed.

```text
➜ checking required tools
✓ clang-format found
✓ cppcheck found
✓ s21lint found
✓ make found
✓ docker found
✓ all required tools found
```

## Project layout

`s21check` automatically detects the project directory:

```text
project-root/
└── src/            ← run from project-root/
    ├── Makefile   ← or run from src/
    ├── *.c
    └── *.h
```

## Dependencies

| Tool | Required | Used for |
|---|---|---|
| `clang-format` | yes | format check using Google style |
| `s21lint` | yes | School 21 style linting |
| `make` | only for `valgrind` | building the test binary |
| `cppcheck` | only for `all` / `static` | static analysis |
| `docker` / `podman` | only for `valgrind` | running Valgrind in a container |

Install `s21lint`:

```sh
npm install --global @s21toolkit/lint
```

## Uninstall

```sh
later
```

## Contributing

Bug reports and pull requests are welcome. Please open an issue first to discuss what you would like to change.

When contributing:

- keep scripts compatible with Bash 3.2+ because it is the default Bash version on macOS;
- run `shellcheck` on any modified shell scripts before submitting;
- test on both macOS and Linux, if possible.

## Bugs

Found something broken? Open an issue at [github.com/kathlind/s21check/issues](https://github.com/kathlind/s21check/issues) and include:

- your OS and Bash version (`bash --version`);
- the command you ran;
- the full output.

## License

MIT

---

> This project is not affiliated with, endorsed by, or connected to School 21 or Sber in any way. It is an independent tool made by students, for students.
