#!/usr/bin/env bash

doctor() {
	local failed=0

	log_info "checking required tools"

	for cmd in clang-format cppcheck s21lint make; do
		if command_exists "$cmd"; then
			log_ok "$cmd found"
		else
			log_err "$cmd missing"
			failed=1
		fi
	done

	if command_exists docker; then
		log_ok "docker found"
	elif command_exists podman; then
		log_ok "podman found"
	else
		log_err "docker or podman missing"
		failed=1
	fi

	if [[ "$failed" -eq 0 ]]; then
		log_ok "all required tools found"
	else
		log_err "some required tools are missing"
	fi

	return "$failed"
}
