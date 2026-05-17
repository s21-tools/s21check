# s21check

School 21 C project checker

It helps you quickly run the most common local checks before pushing your project:
`clang-format`, `s21lint`, `cppcheck`, and Valgrind inside Docker or Podman.

> This project is in beta. Some checks may be improved or changed in future versions.

## Package manager installation

**Brew**
install:
```sh
brew tap s21-tools/s21-tools
brew install s21check
```
uninstall:
```sh
brew uninstall s21check
```

---

## macOS / Linux installer

You can also install `s21check` without a package manager, for example on School 21 ARM machines:

```bash
curl -fsSL https://raw.githubusercontent.com/s21-tools/s21check/main/install.sh | bash
```

If `s21check` is not found after installation, add `~/.local/bin` to your `PATH`.

For Zsh:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

For Bash:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Check installation:

```bash
s21check help
```

Uninstall:

```bash
curl -fsSL https://raw.githubusercontent.com/s21-tools/s21check/main/uninstall.sh | bash
```

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

## Contributing

Bug reports and pull requests are welcome. Please open an issue first to discuss what you would like to change.

When contributing:

- keep scripts compatible with Bash 3.2+ because it is the default Bash version on most systems;
- test on both macOS and Linux, if possible.

## Bugs

Found something broken? Open an issue at [github.com/s21-tools/s21check/issues](https://github.com/s21-tools/s21check/issues) and include:

- your OS and Bash version (`bash --version`);
- the command you ran;
- the full output.

## License

MIT

---

> This project is not affiliated with, endorsed by, or connected to School 21 or Sber in any way. It is an independent tool made by students, for students.
