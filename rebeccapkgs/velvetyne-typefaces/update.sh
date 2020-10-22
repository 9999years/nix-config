#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nix-prefetch pup nixfmt curl
# shellcheck shell=bash
set -e

# {{{ Colors, logging boilerplate
readonly PROG_NAME="$0"

function RESET            { echo -e "\e[0m";  }
function BOLD             { echo -e "\e[1m";  }
function RESET_BOLD       { echo -e "\e[21m"; }
function DIM              { echo -e "\e[2m";  }
function RESET_DIM        { echo -e "\e[22m"; }
function UNDERLINED       { echo -e "\e[4m";  }
function RESET_UNDERLINED { echo -e "\e[24m"; }
function BRRED            { echo -e "\e[31m"; }
function RED              { echo -e "\e[91m"; }
function BRGREEN          { echo -e "\e[32m"; }
function GREEN            { echo -e "\e[92m"; }
function BRYELLOW         { echo -e "\e[33m"; }
function YELLOW           { echo -e "\e[93m"; }
function BRBLUE           { echo -e "\e[34m"; }
function BLUE             { echo -e "\e[94m"; }
function BRPURPLE         { echo -e "\e[35m"; }
function PURPLE           { echo -e "\e[95m"; }
function BRCYAN           { echo -e "\e[36m"; }
function CYAN             { echo -e "\e[96m"; }
function BRGRAY           { echo -e "\e[37m"; }
function GRAY             { echo -e "\e[97m"; }
function RESET_FG         { echo -e "\e[39m"; }

function now { date +%FT%T; }

# _log COLORS LABEL [MESSAGE [...]]
function _log {
    color="$1"
    shift
    level="$1"
    shift
    echo -n "$color$level $PROG_NAME ${color}[$(now)]:" "$@"
    RESET
}
# }}}

function dbg   { _log "$(GRAY)$(DIM)"   "[debug]" "$@"; }
function info  { _log "$(BRGREEN)"      "[info] " "$@"; }
function warn  { _log "$(BRYELLOW)"     "[warn] " "$@"; }
function error { _log "$(BRRED)"        "[error]" "$@"; }
function fatal { _log "$(BOLD)$(BRRED)" "[FATAL]" "$@"; exit 1; }
function cmd   { _log "$(CYAN)"         "[run]  " "\$ $(BOLD)$(UNDERLINED)$*"; }

echo "{ fetchzip, fetchFromGitLab, fetchFromGitHub }:" > srcs.nix.new
echo "[" >> srcs.nix.new

info "Downloading $(UNDERLINED)http://velvetyne.fr$(RESET_UNDERLINED) homepage"
while IFS="" read -r line
do
    font=$(echo "$line" | sed -E 's|/fonts/([^/]+)/|\1|')
    info "Found font $font"
    url=$(curl "http://velvetyne.fr/$line/download/" \
        | pup 'a:contains("clic here.") attr{href}')
    info "Found URL $url"
    case "$url" in
        https://gitlab.com/* )
            dbg "Parsing as GitLab URL"
            remote=$(echo "$url" | sed -E 's|(https://gitlab\.com/[^/]+/[^/]+)/.*$|\1.git|')
            owner=$(echo "$url" | sed -E 's|https://gitlab\.com/([^/]+)/([^/]+)/.*$|\1|')
            repo=$(echo "$url" | sed -E 's|https://gitlab\.com/([^/]+)/([^/]+)/.*$|\2|')
            rev=$(git ls-remote "$remote" HEAD | cut -f1)
            echo "(fetchFromGitLab $(nix-prefetch --quiet --output nix \
                fetchFromGitLab \
                --name "$owner-$repo" \
                --owner "$owner" \
                --repo "$repo" \
                --rev "$rev"))" >> srcs.nix.new
            ;;

        https://github.com/* )
            dbg "Parsing as GitHub URL"
            remote=$(echo "$url" | sed -E 's|(https://github\.com/[^/]+/[^/]+)/.*$|\1.git|')
            owner=$(echo "$url" | sed -E 's|https://github\.com/([^/]+)/([^/]+)/.*$|\1|')
            repo=$(echo "$url" | sed -E 's|https://github\.com/([^/]+)/([^/]+)/.*$|\2|')
            rev=$(git ls-remote "$remote" HEAD | cut -f1)
            echo "(fetchFromGitHub $(nix-prefetch --quiet --output nix \
                fetchFromGitHub \
                --name "$owner-$repo" \
                --owner "$owner" \
                --repo "$repo" \
                --rev "$rev"))" >> srcs.nix.new
            ;;

        *.zip )
            dbg "Parsing as plain zip URL"
            echo "(fetchzip $(nix-prefetch --quiet --output nix \
                fetchzip \
                --name "velvetyne-$font" \
                --no-stripRoot \
                --url "$url"))" >> srcs.nix.new
            ;;

        * )
            fatal "Unrecognized URL format $url"
            ;;
    esac
done < <(curl http://velvetyne.fr/ | pup 'ul.typefaces li a attr{href}')

echo "]" >> srcs.nix.new
info "Reformatting new sources file"
nixfmt srcs.nix.new
mv srcs.nix.new srcs.nix
info "Wrote sources to $(UNDERLINED)srcs.nix$(RESET_UNDERLINED)"
