#!/usr/bin/env bash

oid=$(snmptranslate -IR -On "${1}")
oid_info=$(snmptranslate -Td "${oid}")
echo "${oid}"
echo "${oid_info}"
