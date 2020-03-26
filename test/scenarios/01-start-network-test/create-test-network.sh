#!/usr/bin/env bash 

# source #

# ARGS_PASSED=("$@")

export  ARGS_REQUIRED=(
     "First_organization":org1
     "Second_organization":org2
 )

../create-standard-network.sh $@