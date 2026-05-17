#!/usr/bin/env bash

log_info() {
	printf "➜ %s\n" "$*"
}

log_ok() {
	printf "✓ %s\n" "$*"
}

log_warn() {
	printf "! %s\n" "$*" >&2
}

log_err() {
	printf "✗ %s\n" "$*" >&2
}
