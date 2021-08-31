#!/usr/bin/env bash
#===============================================================================
#
#         FILE:  mkdev.sh
#        USAGE:  mkdev.sh
#  DESCRIPTION:
#
#      OPTIONS:  ---
# REQUIREMENTS:
#
#         BUGS:  ---
#        NOTES:  #
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2020-09-10 14:54:46
#    COPYRIGHT:  (C) 2020-2021 Lewis E. Bogan <lewis.bogan@comcast.net>
# Distributed under terms of the MIT license.
#===============================================================================

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
# Builds production files using the Makefile.
# Globals:
#   green red yellow normal
# Arguments:
#   $1
#===============================================================================
build() {
  echo "${yellow}Building bin/$1...${normal}"
  shift
  if make "$1"; then
    echo "${green}Done!${normal}"
  else
    echo "${red}Oops!${normal}"
  fi
}

# Start the spinner in the background, make note of its process id (pid), and kill the
# spinner on any signal, including our own exit.
spin &
pid=$!
trap 'kill -9 $pid' $(seq 0 15)

if [[ ! -d bin ]]; then
  mkdir bin
fi

build "${name}" dev
