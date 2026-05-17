#!/usr/bin/env bash

run_checks() {
	local failed=0

	check_format || failed=1
	check_lint || failed=1

	if [[ "$failed" -eq 0 ]]; then
		log_ok "all checks passed"
	else
		log_err "some checks failed"
	fi

	return "$failed"
}

run_all_checks() {
	local failed=0

	check_format || failed=1
	check_static || failed=1
	check_lint || failed=1

	if [[ "$failed" -eq 0 ]]; then
		log_ok "all checks passed"
	else
		log_err "some checks failed"
	fi

	return "$failed"
}

check_format() {
	local project_dir
	local failed=0

	project_dir="$(detect_project_dir)" || return 1

	require_cmd clang-format || return 1

	log_info "checking clang-format"
	log_info "project dir: $project_dir"

	if ! has_c_files "$project_dir"; then
		log_err "no .c/.h files found in $project_dir"
		return 1
	fi

	while IFS= read -r file; do
		if ! clang-format --dry-run --Werror --style="{BasedOnStyle: Google}" "$file" >/dev/null 2>&1; then
			log_err "format failed: $file"
			failed=1
		fi
	done < <(find_c_files "$project_dir")

	if [[ "$failed" -eq 0 ]]; then
		log_ok "clang-format passed"
	else
		log_err "clang-format failed"
	fi

	return "$failed"
}

check_static() {
	local project_dir

	project_dir="$(detect_project_dir)" || return 1

	require_cmd cppcheck || return 1

	log_info "running cppcheck"
	log_info "project dir: $project_dir"

	if ! has_c_files "$project_dir"; then
		log_err "no .c/.h files found in $project_dir"
		return 1
	fi

	if cppcheck --enable=all --suppress=missingIncludeSystem "$project_dir"; then
		log_ok "cppcheck passed"
		return 0
	fi

	log_err "cppcheck failed"
	return 1
}

check_lint() {
	local project_dir

	project_dir="$(detect_project_dir)" || return 1

	require_cmd s21lint || return 1

	log_info "running s21lint"
	log_info "project dir: $project_dir"

	if ! has_c_files "$project_dir"; then
		log_err "no .c/.h files found in $project_dir"
		return 1
	fi

	if find_c_files "$project_dir" | xargs s21lint; then
		log_ok "s21lint passed"
		return 0
	fi

	log_err "s21lint failed"
	return 1
}