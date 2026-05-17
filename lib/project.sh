#!/usr/bin/env bash

detect_project_dir() {
	if [[ -d "./src" ]]; then
		(cd ./src && pwd)
		return 0
	fi

	if [[ -f "./Makefile" || -f "./makefile" ]]; then
		pwd
		return 0
	fi

	log_err "project directory not found"
	log_err "run s21check from project root containing ./src or from src directory"
	return 1
}
