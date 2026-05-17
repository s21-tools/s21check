#!/usr/bin/env bash
set -euo pipefail

REPO="kathlind/s21check"
BRANCH="${S21CHECK_BRANCH:-main}"

BIN_DIR="${S21CHECK_BIN_DIR:-$HOME/.local/bin}"
DATA_DIR="${S21CHECK_DATA_DIR:-$HOME/.local/share/s21check}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

info() {
	printf "➜ %s\n" "$*"
}

ok() {
	printf "✓ %s\n" "$*"
}

err() {
	printf "✗ %s\n" "$*" >&2
}

require_cmd() {
	if ! command -v "$1" >/dev/null 2>&1; then
		err "required command not found: $1"
		exit 1
	fi
}

require_cmd curl
require_cmd tar

info "installing s21check"

mkdir -p "$BIN_DIR"
mkdir -p "$DATA_DIR"

ARCHIVE_URL="https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz"

info "downloading $ARCHIVE_URL"

curl -fsSL "$ARCHIVE_URL" -o "$TMP_DIR/s21check.tar.gz"
tar -xzf "$TMP_DIR/s21check.tar.gz" -C "$TMP_DIR"

SRC_DIR="$TMP_DIR/s21check-$BRANCH"

if [[ ! -f "$SRC_DIR/bin/s21check" ]]; then
	err "bin/s21check not found in archive"
	exit 1
fi

if [[ ! -d "$SRC_DIR/lib" ]]; then
	err "lib directory not found in archive"
	exit 1
fi

info "copying files"

cp "$SRC_DIR/bin/s21check" "$BIN_DIR/s21check"
chmod +x "$BIN_DIR/s21check"

rm -rf "${DATA_DIR:?}/lib"
cp -R "$SRC_DIR/lib" "$DATA_DIR/lib"

info "patching library path"

sed -i.bak \
	's|ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"|ROOT_DIR="'"$DATA_DIR"'"|' \
	"$BIN_DIR/s21check"

rm -f "$BIN_DIR/s21check.bak"

ok "s21check installed"

if ! command -v s21check >/dev/null 2>&1; then
	printf "\n"
	info "add this to your shell config:"
	printf "\n"
	printf 'export PATH="$HOME/.local/bin:$PATH"\n'
	printf "\n"
fi

info "try:"
printf "  s21check --help\n"
