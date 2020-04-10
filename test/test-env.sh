#!/usr/bin/env bash

cd ~ ;  a=$?

cd ~ ; a=$(( ${a} | $? ))

echo $a