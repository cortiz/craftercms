#!/usr/bin/env bash


if [ "$(whoami)" == "root" ]; then
	echo -e "\033[38;5;196m"
	echo -e "Crafter CMS cowardly refuses to run as root."
    echo -e "Running as root is dangerous and is not supported."
    echo -e "\033[0m"
	exit 1
fi

DEFAULT_VERSION="$1"
DEFAULT_INSTALL_DIR="$(pwd)" ##DELETE THIS

function ask(){
    printf "$1> "
    read value
  if [  -z "$value" ]; then
    if [ ! -z "$3" ]; then
        value=$3
     else
        echo "Value can't be empty"
        exit 3
     fi
  fi
  eval "$2=$value"
}


function downloadAuth(){
    curl "https://s3.amazonaws.com/downloads.craftercms.org/$1/crafter-cms-authoring.tar.gz" > "$2/crafter-cms-authoring.tar.gz"
    curl "https://s3.amazonaws.com/downloads.craftercms.org/$1/crafter-cms-authoring.tar.gz.sha512" > "$2/crafter-cms-authoring.tar.gz.sha512"
    cd "$2"
    sha512sum -c "$2/crafter-cms-authoring.tar.gz.sha512" > /dev/null
    if [ "$?" -ne "0" ]; then
        echo "Check Sum of $2/crafter-cms-authoring.tar.gz does not match $2/crafter-cms-authoring.tar.gz.sha512"
        exit 4
    else
     echo "Downloaded file OK"
    fi
    cd -
}

function checkForPerms(){
   if [ ! -d "$1" ] | [ ! -r "$1" ] | [ ! -w "$1" ]; then
       echo "$1 is not a directory or user don't have permission"
       exit 5
   fi
}


function checkForBinOrDie(){
    if ! command -v "$1" &> /dev/null ; then
     echo -e "\033[38;5;196m"
        echo  "$1 is needed"
        echo -e "\033[0m"
        exit 2
    fi
}

function preflightcheck(){

    if [ "$(whoami)" == "root" ]; then
        echo -e "\033[38;5;196m"
        echo -e "Crafter CMS cowardly refuses to run as root."
        echo -e "Running as root is dangerous and is not supported."
        echo -e "\033[0m"
        exit 1
    fi

    OSARCH=$(getconf LONG_BIT)
    if [[ $OSARCH -eq "32" ]]; then
      echo -e "\033[38;5;196m"
      echo "CrafterCMS is not supported in a 32bit os"
      echo -e "\033[0m"
      read -r
      exit 5
    fi

    checkForBinOrDie "unzip"
    checkForBinOrDie "tar"
    checkForBinOrDie "curl"
    checkForBinOrDie "java"
    checkForBinOrDie "sha512sum"
}

function logo() {
  echo -e "\033[38;5;196m"
  echo " ██████╗ ██████╗   █████╗  ███████╗ ████████╗ ███████╗ ██████╗      ██████╗ ███╗   ███╗ ███████╗"
  echo "██╔════╝ ██╔══██╗ ██╔══██╗ ██╔════╝ ╚══██╔══╝ ██╔════╝ ██╔══██╗    ██╔════╝ ████╗ ████║ ██╔════╝"
  echo "██║      ██████╔╝ ███████║ █████╗      ██║    █████╗   ██████╔╝    ██║      ██╔████╔██║ ███████╗"
  echo "██║      ██╔══██╗ ██╔══██║ ██╔══╝      ██║    ██╔══╝   ██╔══██╗    ██║      ██║╚██╔╝██║ ╚════██║"
  echo "╚██████╗ ██║  ██║ ██║  ██║ ██║         ██║    ███████╗ ██║  ██║    ╚██████╗ ██║ ╚═╝ ██║ ███████║"
  echo " ╚═════╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝ ╚═╝         ╚═╝    ╚══════╝ ╚═╝  ╚═╝     ╚═════╝ ╚═╝     ╚═╝ ╚══════╝"
  echo -e "\033[0m"
  version
}

function version(){
   echo "Copyright (C) 2007-2018 Crafter Software Corporation. All rights reserved."
   echo "This program comes with ABSOLUTELY NO WARRANTY; for details type."
   echo "This is free software, and you are welcome to redistribute it"
   echo "under certain conditions"
}

function main(){
    preflightcheck
    logo
    echo ""
    ask "Which version of Crafter ($DEFAULT_VERSION)" CRAFTER_VERSION "$DEFAULT_VERSION"
    ask "Where to install Crafter ($DEFAULT_INSTALL_DIR)" CRAFTER_INSTALL_DIR "$DEFAULT_INSTALL_DIR"
    checkForPerms $CRAFTER_INSTALL_DIR
    mkdir "$CRAFTER_INSTALL_DIR/downloads/"
    downloadAuth $CRAFTER_VERSION "$CRAFTER_INSTALL_DIR/downloads/"
    mkdir "$CRAFTER_INSTALL_DIR/crafter-authoring"
    tar xf "$CRAFTER_INSTALL_DIR/downloads/crafter-cms-authoring.tar.gz" --strip 1 -C "$CRAFTER_INSTALL_DIR/crafter-authoring"
}

main
