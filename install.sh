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

install_dir=/usr/local/bin
user=`id -nu`

show_menu()
{
  local choice

  clear
  echo "--------------------------------------------------"
  echo "Installation script for snob utility"
  echo "--------------------------------------------------"
  echo "1. Install supplied binary (Fedora only)"
  echo "2. Update supplied binary from repo (Fedora only)"
  echo "3. Build/install from source"
  echo "4. Update from git source"
  echo "5. Uninstall all (except data files)"
  echo "q. Quit"
  echo

  read -p "Enter choice [Q/q to quit]: " choice
  case $choice in
    1) install_binary ;;
    2) update_binary ;;
    3) build_source ;;
    4) update_source ;;
    5) uninstall_all ;;
    "q" | "Q") exit 0 ;;
  esac
}

install_binary()
{
sudo ln -s $(realpath ./snob) ${install_dir}/snob
  finish_msg
}

update_binary()
{
  git pull
  echo "snob binary upgraded."
  exit 0
}

build_source()
{
  shards install
  make clean
  make
  sudo make install
  finish_msg
}

update_source()
{
  git pull
  shards update
  make clean
  make
  sudo make install
  echo "snob updated from source"
}

uninstall_all()
{
  make clean
  sudo make uninstall
}

setup()
{
  ## Sample
  echo "Sample extras."
}

finish_msg()
{
  cat <<FINISH
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
