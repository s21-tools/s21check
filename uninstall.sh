#!/usr/bin/env bash

set -euo pipefail

APP_NAME="s21check"

INSTALL_PREFIX="${HOME}/.local"
BIN_DIR="${INSTALL_PREFIX}/bin"
DATA_DIR="${INSTALL_PREFIX}/share/${APP_NAME}"

BIN_PATH="${BIN_DIR}/${APP_NAME}"

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

remove_file() {
  local file="$1"

  if [ -e "$file" ]; then
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

main() {
  local os

  os="$(detect_os)"
  info "Detected OS: $os"

  echo "This will remove ${APP_NAME} from:"
  echo "  $BIN_PATH"
  echo "  $DATA_DIR"
  echo

  read -r -p "Continue? [y/N] " answer

  case "$answer" in
    y|Y|yes|YES)
      ;;
    *)
      warn "Uninstall cancelled."
      exit 0
      ;;
  esac

  remove_file "$BIN_PATH"
  remove_dir "$DATA_DIR"

  success "${APP_NAME} uninstalled successfully."

  echo
  echo "If you added this line only for ${APP_NAME}, you may remove it from your shell config:"
  echo
  echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
}

main "$@"
