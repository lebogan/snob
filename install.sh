#!/usr/bin/env bash
#===============================================================================
#
#         FILE:  install.sh
#        USAGE:  ./install.sh
#  DESCRIPTION:  Installer script for snob.
#
#      OPTIONS:  ---
# REQUIREMENTS:  
#
#         BUGS:  ---
#        NOTES:  #
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2018-03-12 19:03
#    COPYRIGHT:  (C) 2018 Lewis E. Bogan <lewis.bogan@comcast.net>
# Distributed under terms of the MIT license.
#===============================================================================

install_dir=/usr/local/bin

prompt ()
{
  # See if the lame SYS-V echo command flags have to be used.
  if test "`/bin/echo 'helloch\c'`" = "helloch\c"
  then
    EFLAG="-n"
    ENDER=""
  else
    EFLAG=""
    ENDER="\c"
  fi
  ECHO="/bin/echo ${EFLAG}"

  ${ECHO} "$1 ${ENDER}"
  read agree
  if test "${agree}" = "y" -o "${agree}" = "Y"
  then
    echo ""
  else
    exit 1
  fi
}

# Copy application to install_dir. If the symlink esists, offer to upgrade the app
# only and exit.
if [ ! -L $install_dir/snob ]
then
  prompt "Do you want to install snob? (y/n)[n] "
  sudo ln -s $(realpath ./snob) $install_dir/snob
else
  prompt "Do you want to upgrade snob? (y/n)[n] "
  git pull
  echo "snob upgraded."
  exit 0
fi

cat <<FINISH

--------------------------------------------------------------------------
Application, snob, has been installed. First run will generate a config
file. Make sure net-snmp is installed and functional. Use over the public
internet is NOT recommended!
--------------------------------------------------------------------------
FINISH
