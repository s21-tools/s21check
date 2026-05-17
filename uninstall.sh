#!/usr/bin/env bash

set -euo pipefail

APP_NAME="s21check"

INSTALL_PREFIX="${HOME}/.local"
BIN_DIR="${INSTALL_PREFIX}/bin"
DATA_DIR="${INSTALL_PREFIX}/share/${APP_NAME}"

BIN_PATH="${BIN_DIR}/${APP_NAME}"

ASSUME_YES=0

info() {
  printf "\033[1;34m[INFO]\033[0m %s\n" "$1"
}

success() {
  printf "\033[1;32m[SUCCESS]\033[0m %s\n" "$1"
}

warn() {
  printf "\033[1;33m[WARN]\033[0m %s\n" "$1"
}

detect_os() {
  case "$(uname -s)" in
    Darwin)
      echo "macos"
      ;;
    Linux)
      echo "linux"
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

usage() {
  cat <<EOF
Usage:
  uninstall.sh [--yes|-y]

Options:
  --yes, -y    Remove s21check without confirmation
  --help, -h   Show this help message
EOF
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --yes|-y)
        ASSUME_YES=1
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        warn "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
    shift
  done
}

remove_file() {
  local file="$1"

  if [ -e "$file" ] || [ -L "$file" ]; then
    rm -f "$file"
    info "Removed file: $file"
  else
    warn "File not found: $file"
  fi
}

remove_dir() {
  local dir="$1"

  if [ -d "$dir" ]; then
    rm -rf "$dir"
    info "Removed directory: $dir"
  else
    warn "Directory not found: $dir"
  fi
}

confirm_uninstall() {
  if [ "$ASSUME_YES" -eq 1 ]; then
    return 0
  fi

  if [ ! -t 0 ]; then
    warn "Non-interactive shell detected."
    warn "Run with --yes to uninstall without confirmation:"
    echo
    echo "  curl -fsSL https://raw.githubusercontent.com/s21-tools/s21check/main/uninstall.sh | bash -s -- --yes"
    exit 1
  fi

  read -r -p "Continue? [y/N] " answer

  case "$answer" in
    y|Y|yes|YES)
      ;;
    *)
      warn "Uninstall cancelled."
      exit 0
      ;;
  esac
}

main() {
  local os

  parse_args "$@"

  os="$(detect_os)"
  info "Detected OS: $os"

  echo "This will remove ${APP_NAME} from:"
  echo "  $BIN_PATH"
  echo "  $DATA_DIR"
  echo

  confirm_uninstall

  remove_file "$BIN_PATH"
  remove_dir "$DATA_DIR"

  success "${APP_NAME} uninstalled successfully."

  echo
  echo "If you added this line only for ${APP_NAME}, you may remove it from your shell config:"
  echo
  echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
}

main "$@"
