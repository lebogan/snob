#!/usr/bin/env bash
#===============================================================================
#
#         FILE:  install.sh
#        USAGE:  install.sh
#  DESCRIPTION:  Installation script for snob utility.
#
#      OPTIONS:  ---
# REQUIREMENTS:
#
#         BUGS:  ---
#        NOTES:  #
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2019-05-03 09:39
#    COPYRIGHT:  (C) 2019 Lewis E. Bogan <lewis.bogan@comcast.net>
# Distributed under terms of the MIT license.
#===============================================================================
[ -n "BASH_VERSION" ] && shopt -s extglob

install_dir=/usr/local/bin
mandir=/usr/local/share/man
data_dir=$HOME/.backup
user=$(id -nu)
name=snob

show_menu() {
    local choice

    clear
    echo "--------------------------------------------------"
    echo "Installation script for snob utility"
    echo "--------------------------------------------------"
    echo "1. Install supplied binary (Ubuntu only)"
    echo "2. Update supplied binary from repo (Ubuntu only)"
    echo "3. Build/install from source (except RaspberryPi)"
    echo "4. Update from git source (except RaspberryPi)"
    echo "5. Build/install for RaspberryPi 3/4"
    echo "6. Uninstall all (except data files)"
    echo "q. Quit"
    echo

    read -p "Enter choice [Q/q to quit]: " choice
    case $choice in
        1) install_binary ;;
        2) update_binary ;;
        3) build_source ;;
        4) update_source ;;
        5) build_raspi ;;
        6) uninstall_all ;;
        "q" | "Q") exit 0 ;;
    esac
}

install_binary() {
    sudo ln -s $(realpath ./bin/snob) ${install_dir}/snob
    sudo install -m 0755 -d ${mandir}/man1
    sudo install -m 0644 man/${name}.1 ${mandir}/man1
    sudo install -m 0644 man/${name}.5 ${mandir}/man1

    finish_msg
}

update_binary() {
    git pull
    echo "${name} binary upgraded."
    exit 0
}

build_source() {
    shards install
    make clean
    make
    sudo make install
    finish_msg
}

update_source() {
    git pull
    shards update
    make clean
    make
    sudo make install
    echo "${name} updated from source"
}

build_libcrystal_a() {
    cd bin
    wget https://raw.githubusercontent.com/crystal-lang/crystal/master/src/ext/sigfault.c
    cc -c -o sigfault.o sigfault.c
    ar -rcs libcrystal.a sigfault.o
    rm sigfault.*
    cd -
}

build_raspi() {
    git stash
    git pull
    make clean
    if [ ! -f "bin/libcrystal.a" ]; then
        build_libcrystal_a
    fi
    sed -i -e "s|/usr/share/crystal/src/ext/libcrystal.a|bin/libcrystal.a|g" rpibuild.sh
    bash rpibuild.sh
    sudo make install
    finish_msg
}

uninstall_all() {
    make clean
    sudo make uninstall
}

setup() {
    ## Sample
    echo "Sample extras."
}

finish_msg() {
    cat << FINISH
--------------------------------------------------------------------------
Application, snob, has been installed. First run will generate a config
file. Make sure net-snmp is installed and functional. Use over the public
internet is NOT recommended!
See snob --help for further info as needed.
See also the man files snob.1 and snob.5.
--------------------------------------------------------------------------
FINISH
}

show_menu
