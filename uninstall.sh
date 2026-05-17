#!/usr/bin/env bash
set -euo pipefail

BIN_DIR="${S21CHECK_BIN_DIR:-$HOME/.local/bin}"
DATA_DIR="${S21CHECK_DATA_DIR:-$HOME/.local/share/s21check}"

rm -f "$BIN_DIR/s21check"
rm -rf "$DATA_DIR"

echo "s21check removed"
