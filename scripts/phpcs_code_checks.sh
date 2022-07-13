#!/bin/bash
BIN="./vendor/bin"

# Check if jq is installed
function checkIfPhpCsExist()
{
    if [ ! -f "$BIN/phpcs" ]
    then
        false
    fi

    return
}

function runPhpCs()
{
    # Retrieve staged files
    FILES=$(git diff --cached --name-only --diff-filter=ACMR HEAD)
    
    # PHPCS Command
    PHPCS=("$BIN/phpcs" "--filter=gitstaged" "--encoding=utf-8" "-p" ".")

    # Some colors
    NOCOLOR='\033[0m'
    RED='\033[0;31m'
    ORANGE='\033[0;33m'
    CYAN='\033[0;36m'
    LIGHTRED='\033[1;31m'
    YELLOW='\033[1;33m'

    # Run the sniffer
    echo -e "------------------------"
    echo -e "${CYAN}Running PHP Code Sniffer using the $STANDARD standard${NOCOLOR}"
    echo -e "------------------------"
    "${PHPCS[@]}"

    # Syntax OK
    if [ $? == 0 ]
    then
        echo -e "${YELLOW}No violations detected{NOCOLOR}"
        exit 0
    fi

    # Fix automatically?
    read -p "Automatically fix violations when possible? [Y/n]: " < /dev/tty
    if [[ ! ("$REPLY" == 'y' || "$REPLY" == 'Y' || "$REPLY" == '') ]]
    then
        echo
        exit 1
    fi

    # Run the beautifier
    PHPCBF=("$BIN/phpcbf" "--standard=$STANDARD" "--filter=gitstaged" ".")
    "${PHPCBF[@]}"

    # Stage the files
    echo -e "${CYAN}Re-staging updated files${NOCOLOR}"
    git add ${FILES}

    # Run the sniffer again
    "${PHPCS[@]}"

    # Some violations remain
    if [ $? != 0 ]
    then
        echo -e "${RED}PHP Code Sniffer was not able to fix all of the violations, please fix the remaining ones manually or commit with the --no-verify option${NOCOLOR}"
        exit 1
    fi
}

if checkIfPhpCsExist; then
    runPhpCs
fi