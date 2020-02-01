#! /usr/bin/env nix-shell
#! nix-shell -i bash --packages curl perlPackages.MozillaCA
# shellcheck shell=bash
set -e

# 🤦‍♀️
# https://stackoverflow.com/a/246128
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$SCRIPT_DIR"

[[ -f default.nix ]] && mv default.nix .default.nix.bak
curl --remote-name https://raw.githubusercontent.com/9999years/nix-query/master/default.nix
if [[ -f .default.nix.bak ]]
then
    if diff --color .default.nix.bak default.nix
    then
        echo "No updates to be made."
        exit 0
    fi

    prompt="Looks good?"
    have_answer=""

    while [[ -z "$have_answer" ]]
    do
        echo -n "$prompt [Y/n] "
        read -r confirm
        if [[ "$confirm" =~ [yY](es)?|[nN]o? ]]
        then
            have_answer=1
        else
            prompt="Looks good? (Please enter one of 'y', 'yes', 'n', 'no'.)"
        fi
    done

    if [[ "$confirm" =~ [yY](es)? ]]
    then
        rm .default.nix.bak
    elif [[ "$confirm" =~ [nN]o? ]]
    then
        mv .default.nix.bak default.nix
    fi
fi