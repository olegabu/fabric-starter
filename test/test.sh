#!/bin/bash
org='org1'
API_org1_IP='192.168.0.1'
var_name="API_${org}_IP"
echo $var_name
echo "${!var_name}"
