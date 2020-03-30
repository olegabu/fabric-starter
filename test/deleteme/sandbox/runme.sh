#!/usr/bin/env bash


ARGS_PASSED=("$@")




echo "${ARGS_PASSED[@]}"


cat < (envsubst <(echo "a") )