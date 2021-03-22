#!/usr/bin/env bash

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
normal=$(tput sgr0)
NAME='backup'

spin() {
    spinner='/|\-/|\-'
    while :; do
        for i in $(seq 0 7); do
            echo -n "${spinner:i:1}"
            echo -en "\010"
            sleep .5
        done
    done
}

if [[ ! -d bin ]]; then
    mkdir bin
fi

spin &
pid=$!

echo -n "Building bin/${NAME} -> "

trap "kill -9 $pid" $(seq 0 15)
make prod
make man
make raspi

if [ "$?" -eq "0" ]; then
    echo "${green}Done!${normal}"
else
    kill -9 $pid
fi
