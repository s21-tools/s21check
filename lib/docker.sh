#!/usr/bin/env bash

detect_container_runtime() {
	if command_exists docker; then
		printf "docker\n"
		return 0
	fi

	if command_exists podman; then
		printf "podman\n"
		return 0
	fi

	log_err "docker or podman is required for valgrind"
	return 1
}

run_docker_valgrind() {
	local test_binary="${1:-}"

	if [[ -z "$test_binary" ]]; then
		log_err "test binary is required"
		log_err "usage: s21check valgrind <test-binary>"
		return 2
	fi

	local image="s21check-valgrind"
	local project_dir
	local runtime
	local dockerfile="$ROOT_DIR/lib/Dockerfile"

	project_dir="$(detect_project_dir)" || return 1
	runtime="$(detect_container_runtime)" || return 1

	if [[ -z "$("$runtime" images -q "$image" 2>/dev/null)" ]]; then
		log_info "building container image: $image"
		log_info "runtime: $runtime"

		if ! "$runtime" build -t "$image" -f "$dockerfile" "$(dirname "$dockerfile")"; then
			log_err "failed to build container image"
			return 1
		fi
	else
		log_info "using existing container image: $image"
	fi

	log_info "running valgrind in container"
	log_info "project dir: $project_dir"
	log_info "test binary: ./$test_binary"
	log_info "valgrind log: $project_dir/valgrind.log"

	"$runtime" run --rm \
		--cap-add=SYS_PTRACE \
		-v "$project_dir:/app" \
		-w /app \
		--user "$(id -u):$(id -g)" \
		-e CK_FORK=no \
		-e TEST_BINARY="$test_binary" \
		"$image" \
		bash -lc '
			set -e

			make test > /dev/null 2>&1

			if [ ! -x "./$TEST_BINARY" ]; then
				echo "test binary not found or not executable: ./$TEST_BINARY"
				echo "hint: pass the binary name explicitly:"
				echo "  s21check valgrind <test-binary>"
				exit 1
			fi

			valgrind \
				--leak-check=full \
				--show-leak-kinds=all \
				--track-origins=yes \
				"./$TEST_BINARY" >> valgrind.log 2>&1
		'

	local status=$?

	if [[ "$status" -eq 0 ]]; then
		log_ok "valgrind passed"
	else
		log_err "valgrind failed"
	fi

	return "$status"
}