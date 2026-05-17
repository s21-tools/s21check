#!/usr/bin/env bash

usage() {
	cat <<'EOF'
s21check

School 21 C project checker.

Usage:
  s21check [command]

Commands:
  all                     Run format, static and lint checks
  format                  Check C/H files with clang-format
  static                  Run cppcheck
  lint                    Run s21lint
  valgrind <test-binary>  Run make test and Valgrind for the given test binary
  doctor                  Check required tools
  help                    Show this help

Default:
  s21check                Run format and lint checks

Project layout:
  s21check can be run from:
    1. project root containing ./src
    2. src directory containing Makefile

Examples:
  s21check
  s21check all
  s21check format
  s21check static
  s21check lint
  s21check doctor
  s21check valgrind test
  s21check valgrind s21_decimal_test
EOF
}
