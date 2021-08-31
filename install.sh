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
#    COPYRIGHT:  (C) 2021 Lewis E. Bogan <lewis.bogan@comcast.net>
# Distributed under terms of the MIT license.
#===============================================================================

# Global vars
install_dir=/usr/local/bin
mandir=/usr/local/share/man
data_dir=$HOME/.snob
name=snob

# Color constants using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
normal=$(tput sgr0)

# Source operating system information as environment variables
if [ -f /etc/os-release ]; then
  source /etc/os-release
  OS=$PRETTY_NAME
  SYSID=$ID
fi

#===============================================================================
# Waits for any key to be pressed, no echo, one character.
# Locals:
#   None
# Arguments:
#   None
#===============================================================================
pause() {
  read -srn1 -p "Press any key to continue"
}

#===============================================================================
# Displays a menu of installation options.
# Locals:
#   choice
# Arguments:
#   None
#===============================================================================
show_menu() {
  local choice

  clear
  echo "--------------------------------------------------"
  echo "Installation script for snob utility"
  echo "--------------------------------------------------"
  echo "a. Install supplied binary (Ubuntu only)"
  echo "b. Update supplied binary from repo (Ubuntu only)"
  echo "c. Build/install from source (except RaspberryPi)"
  echo "d. Update from git source (except RaspberryPi)"
  echo "e. Install binary for RaspberryPi 4 (armv7l)"
  echo "f. Install binary for RaspberryPi 3 (armv6k)"
  echo "g. Install binary for Centos/RedHat"
  echo "h. Install binary for Debian/Ubuntu/Mint"
  echo "i. Install binary for RaspberryPi (aarch64)"
  echo "j. Uninstall all (except data files)"
  echo "q. Quit"
  echo

  read -r -p "Enter choice [Q/q to quit]: " choice
  case $choice in
  "a") install_binary ;;
  "b") update_binary ;;
  "c") build_source ;;
  "d") update_source ;;
  "e") build_raspi4 ;;
  "f") build_raspi3 ;;
  "g") build_centos ;;
  "h") build_debian ;;
  "i") build_aarch64 ;;
  "j") uninstall_all ;;
  "q" | "Q") exit 0 ;;
  esac
}

#===============================================================================
# Installs a symbolic soft link to ${install_dir} and man files.
# Locals:
#   None
# Arguments:
#   None
#===============================================================================
install_binary() {
  if [ -f ${install_dir}/${name} ]; then
    cat <<WARNING
${red}Warning: ${normal}${install_dir}/${name} already exists!
Try uninstall option first and reinstall binary, or
try 'update binary' or 'build from source' instead!
WARNING
    exit 1
  else
    sudo ln -s "$(realpath ./bin/snob) ${install_dir}/snob"
    sudo install -m 0755 -d ${mandir}/man1
    sudo install -m 0644 man/${name}.1 ${mandir}/man1
    sudo install -m 0644 man/${name}.5 ${mandir}/man1
    install_snmp
    finish_msg
  fi
}

#===============================================================================
# Pulls a fresh copy from repo server for use with the symbolic soft link.
# Locals:
#   None
# Arguments:
#   None
#===============================================================================
update_binary() {
  git pull
  echo "${yellow}${name} binary upgraded.${normal}"
  exit 0
}

#===============================================================================
# Compiles and installs binary and docs using Crystal compiler.
# Locals:
#   None
# Arguments:
#   None
#===============================================================================
build_source() {
  shards install
  make clean
  make
  sudo make install
  install_snmp
  finish_msg
}

#===============================================================================
# Recompiles and installs binary and docs using Crystal compiler.
# Locals:
#   None
# Arguments:
#   None
#===============================================================================
update_source() {
  git pull
  shards update
  make clean
  make
  sudo make install
  echo "${yellow}${name} updated from source.${normal}"
}

#===============================================================================
# Generic function to install a list of snmp utilities with no noise.
# Locals:
#   None
# Arguments:
#   None
#===============================================================================
install_snmp() {
  case $SYSID in
  ubuntu | raspbian | debian)
    sudo apt update -y
    sudo apt-get install -y snmp snmp-mibs-downloader >/dev/null 2>&1
    if grep '^mibs :' /etc/snmp/snmp.conf; then
      sudo sed -i -e "s/mibs :/#mibs :/" /etc/snmp/snmp.conf
    fi
    ;;
  centos)
    sudo dnf install -y snmp snmp-mibs-downloader >/dev/null 2>&1
    ;;
  *)
    echo "${green}I'm on $OS - no install available${normal}!"
    ;;
  esac
}

#===============================================================================
# Installs libraries for Debian-based OS's
# Locals:
#   None
# Arguments:
#   $@
#===============================================================================
install_deb_libs() {
  sudo apt-get install -y "$@" >/dev/null 2>&1
}

#===============================================================================
# Installs libraries for Redhat-based OS's
# Locals:
#   None
# Arguments:
#   $@
#===============================================================================
install_rpm_libs() {
  sudo dnf config-manager --set-enabled powertools
  sudo dnf install -y "$@" >/dev/null 2>&1
}

#===============================================================================
# Builds binary for RaspberryPi Model 4 running Raspbian (armv7l) by linking the
# cross-compiled object file.
# Locals:
#   None
# Arguments:
#   None
#===============================================================================
build_raspi4() {
  git stash
  git pull
  make clean
  install_snmp
  install_deb_libs gcc make libssl-dev libpcre3-dev libevent-dev libgc-dev libyaml-dev libreadline-dev
  bash scripts/rpibuild4.sh
  sudo make install
  finish_msg
}

#===============================================================================
# Builds binary for RaspberryPi Model 4 running Ubuntu (armv7l) by linking the
# cross-compiled object file.
# Locals:
#   None
# Arguments:
#   None
#===============================================================================
build_aarch64() {
  git stash
  git pull
  make clean
  install_snmp
  install_deb_libs gcc make libssl-dev libpcre3-dev libevent-dev libgc-dev libyaml-dev libreadline-dev
  bash scripts/rpibuild64.sh
  sudo make install
  finish_msg
}
#===============================================================================
# Builds binary for RaspberryPi Model 3 running Raspbian (armv6k) by linking the
# cross-compiled object file.
# Locals:
#   None
# Arguments:
#   None
#===============================================================================
build_raspi3() {
  git stash
  git pull
  make clean
  install_snmp
  install_deb_libs gcc make libssl-dev libpcre3-dev libevent-dev libgc-dev libyaml-dev libreadline-dev
  bash scripts/rpibuild3.sh
  sudo make install
  finish_msg
}

#===============================================================================
# Builds binary for Rpm-based OS's by linking the cross-compiled object file.
# Locals:
#   None
# Arguments:
#   None
#===============================================================================
build_centos() {
  git stash
  git pull
  make clean
  install_snmp
  install_rpm_libs gcc make readline-devel pcre-devel gc-devel libevent-devel
  bash scripts/centosbuild.sh
  sudo make install
  finish_msg
}

#===============================================================================
# Builds binary for Debian-based OS's by linking the cross-compiled object file.
# Locals:
#   None
# Arguments:
#   None
#===============================================================================
build_debian() {
  git stash
  git pull
  make clean
  install_snmp
  install_deb_libs gcc make libssl-dev libpcre3-dev libevent-dev libgc-dev libyaml-dev libreadline-dev
  bash scripts/debianbuild.sh
  sudo make install
  finish_msg
}

#===============================================================================
# Removes binary, links, and docs.
# Locals:
#   None
# Arguments:
#   None
#===============================================================================
uninstall_all() {
  make clean
  sudo make uninstall
  cat <<UNINSTALL
${yellow}The config directory ${data_dir} was not deleted.
Do that manually if you wish to totally remove the snob
application.${normal}
UNINSTALL
}

#===============================================================================
# Displays post installation info on application.
# Locals:
#   None
# Arguments:
#   None
#===============================================================================
finish_msg() {
  cat <<FINISH
--------------------------------------------------------------------------
Application, ${name}, has been installed. First run will generate a config
file. Make sure net-snmp is installed and functional. ${red}Use over the public
internet is NOT recommended!${normal}

${green}See ${name} --help for further info as needed.
See also the man files ${name}.1 and ${name}.5.${normal}
--------------------------------------------------------------------------
FINISH
}

show_menu
