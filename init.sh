#! /usr/bin/env bash
set -e

# {{{ Colors, logging functions
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
function UL               { echo "$(UNDERLINED)$*$(RESET_UNDERLINED)"; }

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

function dbg   { _log "$(GRAY)"         "[debug]" "$@"; }
function info  { _log "$(BRGREEN)"      "[info] " "$@"; }
function warn  { _log "$(BRYELLOW)"     "[warn] " "$@"; }
function error { _log "$(BRRED)"        "[error]" "$@"; }
function fatal { _log "$(BOLD)$(BRRED)" "[FATAL]" "$@"; exit 1; }
function cmd   { _log "$(CYAN)"         "[run]  " "\$ $(BOLD)$(UNDERLINED)$*"; }
# }}}

readonly USAGE="Usage: ./init.sh [-h|--help]"
while (( "$#" ))
do
	case "$1" in
		-h|--help)
			echo "$USAGE"
			cat <<-'EOF'
				1. If hosts/this.nix doesn't exist, creates it pointing to `hostname`
				2. If hardware-configuration.nix doesn't exist, links it to /etc/nixos/hardware-configuration.nix
				   on NixOS or runs `sudo nixos-generate-config` if running in /etc/nixos
			EOF
			exit
			;;
	esac
	shift
done

if [[ -h hosts/this.nix ]]; then
	dbg "$(UL hosts/this.nix) is already a symlink pointing to $(UL "$(readlink hosts/this.nix)")"
elif [[ -e hosts/this.nix ]]; then
	error "$(UL hosts/this.nix) exists, but it's not a symlink."
	error "This seems incorrect, and will likely cause problems when running $(UL nixos-rebuild)"
else
	HOSTNAME="$(hostname)"
	info "creating a symlink at $(UL hosts/this.nix) pointing to $(UL "hosts/$HOSTNAME.nix")"
	pushd hosts || fatal "failed to cd to hosts"
	ln -s "$(hostname).nix" this.nix
	popd || fatal "failed to popd from hosts"
fi

if [[ -h hardware-configuration.nix ]]; then
	dbg "$(UL hardware-configuration.nix) is already a symlink pointing to to $(UL "$(readlink hardware-configuration.nix)")"
elif [[ -f hardware-configuration.nix ]]; then
	dbg "$(UL hardware-configuration.nix) already exists"
elif [[ "$(pwd)" == /etc/nixos && ! -e hardware-configuration.nix ]]; then
	info "$(UL "$(pwd)/hardware-configuration.nix") doesn't exist in /etc/nixos; generating now"
	cmd "sudo nixos-generate-config"
	sudo nixos-generate-config
elif [[ "$(uname -v)" = *NixOS* ]]; then
	info "creating a symlink at $(UL hardware-configuration.nix) pointing to $(UL /etc/nixos/hardware-configuration.nix)"
	ln -s /etc/nixos/hardware-configuration.nix hardware-configuration.nix
fi
