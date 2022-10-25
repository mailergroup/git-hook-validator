#!/bin/bash

# Check if jq is installed
function checkIfJqExists()
{
    if ! [ -x "$(command -v jq)" ]; then
        echo -e "\`commit-msg\` hook cannot be run because jq is missing."
        exit 1
    fi
}

# Check if config file exists
function checkIfBranchConfigFileExists()
{
    if [[ ! -f "$CONFIG" ]]; then
        echo -e "Hook config file is missing. To learn how to set one, please see a README."
        exit 0
    fi
}

# Set configuration path
# Configuration can either be part of existing repo or a path stored in env variable
# Local configuration overrides global configuration
function setBranchConfigurationPath()
{
    localConfig="$PWD/.git/hooks/allowed-branch-names-config.json"
    
    if [ -f "$localConfig" ]; then
        CONFIG=$localConfig
    elif [ -n "$GIT_BRANCH_NAMES_VALIDATION_CONFIG" ]; then
        CONFIG=$GIT_BRANCH_NAMES_VALIDATION_CONFIG
    fi
}

# Loads configuration from a file
function loadBranchConfiguration()
{
    isEnabled=$(jq -r .enabled "$CONFIG")

    if [[ ! $isEnabled ]]; then
        exit 0
    fi

    types=($(jq -r '.types[]' "$CONFIG"))
    mainBranch=$(jq -r .main_branch_name "$CONFIG")
    developBranch=$(jq -r .develop_branch_name "$CONFIG")
}

# Dynamically build regular expression used for branch name validation
function buildBranchRegex()
{
    loadBranchConfiguration
    
    regexp="^((${mainBranch}|${developBranch}))|("

    for type in "${types[@]}"
    do
        regexp="${regexp}$type|"
    done

    regexp="${regexp%|})\/[a-z0-9._-]+$"
}

function displayOutput()
{
    NOCOLOR='\033[0m'
    RED='\033[0;31m'
    ORANGE='\033[0;33m'
    CYAN='\033[0;36m'
    LIGHTRED='\033[1;31m'
    YELLOW='\033[1;33m'

    echo -e "\n${RED}[Invalid Branch Name]${NOCOLOR}"
    echo -e "------------------------"
    echo -e "${ORANGE}Allowed branch types:${NOCOLOR} ${types[@]}"
    echo -e "${ORANGE}Example:${NOCOLOR} feature/issue-666"
    echo -e "${ORANGE}You should rename your branch to a valid name and try again or your commit will be rejected."
}

# Init the hook
setBranchConfigurationPath
checkIfBranchConfigFileExists
checkIfJqExists
loadBranchConfiguration

# Get the first line of a commit message
localBranch="$(git rev-parse --abbrev-ref HEAD)"

buildBranchRegex

# Validate commit message agains regexp
if [[ ! $localBranch =~ $regexp ]]; then
    displayOutput
    exit 1
fi