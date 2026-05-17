#!/usr/bin/env bash

command_exists() {
	command -v "$1" >/dev/null 2>&1
}

require_cmd() {
	local cmd="$1"

	if ! command_exists "$cmd"; then
		log_err "required command not found: $cmd"
		return 1
	fi

	return 0
}

find_c_files() {
	local project_dir="$1"

	find "$project_dir" -type f \( -name "*.c" -o -name "*.h" \)
}

has_c_files() {
	local dir="$1"

	find "$dir" -type f \( -name "*.c" -o -name "*.h" \) 2>/dev/null | grep -q .
}
