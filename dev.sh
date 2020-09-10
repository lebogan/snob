# @Author: Lewis E. Bogan
# @Date:   2020-09-10 14:54:46
# @Last Modified by:   Lewis E. Bogan
# @Last Modified time: 2020-09-10 15:35:03
#!/usr/bin/env bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
NAME='snob'

prompt() {
    read answer
    echo "$answer"
}

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
make dev

if [ "$?" -eq "0" ]; then
    echo "Done"
else
    kill -9 $pid
fi

echo -e "${GREEN}Build ${NAME} for RaspberryPi? Y/n${NC}"
result="$(prompt)"
if [ "${result}" == "n" ]; then
    :
else
    make raspi
fi
