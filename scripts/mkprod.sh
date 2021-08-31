#!/usr/bin/env bash
#===============================================================================
#
#         FILE:  mkprod.sh
#        USAGE:  mkprod.sh
#  DESCRIPTION:  Builds release binaries and cross-compiles object files for
#                non Ubuntu architectures.
#
#      OPTIONS:  ---
# REQUIREMENTS:
#
#         BUGS:  ---
#        NOTES:  #
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2017-11-10 10:19
#    COPYRIGHT:  (C) 2017-2021 Lewis E. Bogan <lewis.bogan@comcast.net>
#    GIT REPOS:  git remote add origin git@earthforge.earthsea.local:lewisb/snob.git
#             :  git remote set-url --add --push origin git@github.com:lebogan/snob.git
#                git push -u origin master
# Distributed under terms of the MIT license.
#===============================================================================

# Global variables with color vars using tput.
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
normal=$(tput sgr0)
name='snob'

#===============================================================================
# Print the 'ith' character of the spinner variable, backspace, then the next ...
# Sleep .5 then loop again indefinitely until killed.
# Locals:
#   spinner
# Arguments:
#   None
#===============================================================================
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

#===============================================================================
# Builds production files using the Makefile by cycling through $@.
# Globals:
#   name
#   green red yellow normal
# Arguments:
#   $@
#===============================================================================
build_prod() {
  echo "${yellow}Building bin/${name}...${normal}"
  while [[ "$#" -gt "0" ]]; do
    if make "$1"; then
      echo "${green}Finished building $1.${normal}"
    else
      echo "${red}Error building $1!${normal}"
    fi
    shift
  done
}

# Start the spinner in the background, make note of its process id (pid), and kill the
# spinner on any signal, including our own exit.
spin &
pid=$!
trap 'kill -9 $pid' $(seq 0 15)

if [[ ! -d bin ]]; then
  mkdir bin
fi

build_prod prod man docs raspi3 raspi4 raspi64 centos debian
