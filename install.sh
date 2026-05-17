#!/usr/bin/env bash

set -euo pipefail

REPO="s21-tools/s21check"
APP_NAME="s21check"

INSTALL_PREFIX="${HOME}/.local"
BIN_DIR="${INSTALL_PREFIX}/bin"
DATA_DIR="${INSTALL_PREFIX}/share/${APP_NAME}"

BIN_PATH="${BIN_DIR}/${APP_NAME}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

info() {
  printf "\033[1;34m[INFO]\033[0m %s\n" "$1"
}

success() {
  printf "\033[1;32m[SUCCESS]\033[0m %s\n" "$1"
}

warn() {
  printf "\033[1;33m[WARN]\033[0m %s\n" "$1"
}

error() {
  printf "\033[1;31m[ERROR]\033[0m %s\n" "$1" >&2
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    error "Required command not found: $1"
    exit 1
  fi
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
      error "Unsupported OS: $(uname -s)"
      exit 1
      ;;
  esac
}

ensure_path_hint() {
  case ":$PATH:" in
    *":$BIN_DIR:"*)
      ;;
    *)
      warn "$BIN_DIR is not in your PATH."
      echo
      echo "Add this line to your shell config:"
      echo
      echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
      echo
      echo "For zsh:"
      echo "  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc"
      echo "  source ~/.zshrc"
      echo
      echo "For bash:"
      echo "  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc"
      echo "  source ~/.bashrc"
      echo
      ;;
  esac
}

download_latest_release() {
  local url

  url="https://github.com/${REPO}/archive/refs/heads/main.tar.gz"

  info "Downloading ${APP_NAME} from ${REPO}..."
  info "URL: $url"

  curl -fsSL "$url" -o "$TMP_DIR/source.tar.gz"
}

extract_archive() {
  info "Extracting archive..."

  tar -xzf "$TMP_DIR/source.tar.gz" -C "$TMP_DIR"

  SRC_DIR="$(find "$TMP_DIR" -maxdepth 1 -type d -name "${APP_NAME}-*" | head -n 1)"

  if [ -z "${SRC_DIR:-}" ] || [ ! -d "$SRC_DIR" ]; then
    error "Failed to find extracted source directory"
    exit 1
  fi
}

install_files() {
  info "Installing files..."

  mkdir -p "$BIN_DIR"
  mkdir -p "$DATA_DIR"

  if [ ! -f "$SRC_DIR/bin/${APP_NAME}" ]; then
    error "Missing bin/${APP_NAME} in source"
    exit 1
  fi

  if [ ! -d "$SRC_DIR/lib" ]; then
    error "Missing lib directory in source"
    exit 1
  fi

  rm -rf "$DATA_DIR/lib"

  cp "$SRC_DIR/bin/${APP_NAME}" "$BIN_PATH"
  cp -R "$SRC_DIR/lib" "$DATA_DIR/lib"

  chmod +x "$BIN_PATH"

  patch_root_dir
}

patch_root_dir() {
  info "Patching ROOT_DIR in ${BIN_PATH}..."

  if grep -q '^ROOT_DIR=' "$BIN_PATH"; then
    sed -i.bak "s|^ROOT_DIR=.*|ROOT_DIR=\"${DATA_DIR}\"|" "$BIN_PATH"
    rm -f "${BIN_PATH}.bak"
  else
    error "Could not find ROOT_DIR variable in ${BIN_PATH}"
    exit 1
  fi
}

main() {
  local os

  os="$(detect_os)"
  info "Detected OS: $os"

  require_cmd curl
  require_cmd tar
  require_cmd find
  require_cmd sed

  download_latest_release
  extract_archive
  install_files

  success "${APP_NAME} installed successfully."
  echo
  echo "Installed binary:"
  echo "  $BIN_PATH"
  echo
  echo "Installed data:"
  echo "  $DATA_DIR"
  echo

  ensure_path_hint

  if command -v "$APP_NAME" >/dev/null 2>&1; then
    echo "Try:"
    echo "  ${APP_NAME} help"
  else
    echo "After updating PATH, try:"
    echo "  ${APP_NAME} help"
  fi
}

main "$@"
