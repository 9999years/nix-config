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

declare diff_hw_config update_hw_config force_hw_config

readonly USAGE="Usage: ./init.sh [-h|--help] [--diff] [--update] [--force]"
while (( "$#" ))
do
	case "$1" in
		-h|--help)
			echo "$USAGE"
			cat <<-'EOF'
				1. If hosts/this.nix doesn't exist, creates it pointing to `hostname`
				2. If hardware-configuration.nix doesn't exist, links it to
				   hosts/$(hostname)-hardware-configuration.nix on NixOS or runs
				   `sudo nixos-generate-config` if running in /etc/nixos

				Options:

				    --diff      Show what would change if ./init.sh was run with --update
				    --update    Update hardware-configuration.nix with `nixos-generate-config`
				    --force     With --update, overwrite changes to
				                hosts/$(hostname)-hardware-configuration.nix even if
				                uncommitted changes exist in the repo
			EOF
			exit
			;;

		--diff|--dry-run)
			diff_hw_config=1
			;;

		--update)
			update_hw_config=1
			;;

		--force)
			force_hw_config=1
			;;
	esac
	shift
done

if [[ -h hosts/this.nix ]]; then
	dbg "$(UL hosts/this.nix) is already a symlink pointing to $(UL "hosts/$(readlink hosts/this.nix)")"
elif [[ -e hosts/this.nix ]]; then
	error "$(UL hosts/this.nix) exists, but it's not a symlink."
	error "This seems incorrect, and will likely cause problems when running $(UL nixos-rebuild)"
else
	HOSTNAME=$(hostname)
	info "creating a symlink at $(UL hosts/this.nix) pointing to $(UL "hosts/$HOSTNAME.nix")"
	pushd hosts > /dev/null || fatal "failed to cd to hosts"
	ln -s "$(hostname).nix" this.nix
	popd > /dev/null || fatal "failed to popd from hosts"
fi

local_hw="hosts/$HOSTNAME-hardware-configuration.nix"
if [[ -n "$diff_hw_config" ]]; then
	hw_config="$local_hw"
	if [[ ! -e "$hw_config" ]] && [[ -e hardware-configuration.nix ]]; then
		hw_config="hardware-configuration.nix"
	fi
	info "Diff if \`nixos-generate-config\` was run:"
	if command -v delta > /dev/null; then
		nixos-generate-config --show-hardware-config \
			| diff --report-identical-files --new-file --unified --ignore-all-space \
				"$hw_config" - \
			| delta
	else
		nixos-generate-config --show-hardware-config \
			| diff --report-identical-files --new-file --unified --ignore-all-space \
				"$hw_config" -
	fi
fi

declare hw_modified
# grep's --line-regexp flag is misleading here; it means "the pattern must
# match the entire line" and applies even in --fixed-strings mode.
if git status --porcelain --untracked-files \
	| grep -E '^\?\?|^A |^ M' \
	| cut -c 4- \
	| grep --fixed-strings --line-regexp "$local_hw"; then
	hw_modified=1
fi

if [[ -n "$update_hw_config" ]]; then
	if [[ -n "$hw_modified" ]]; then
		if [[ -z "$force_hw_config" ]]; then
			error "there are uncommitted changes to $(UL "$local_hw"); refusing to overwrite with \`nixos-generate-config\`"
			error "either commit your changes or pass --force to overwrite local files"
			unset update_hw_config
		else
			info "there are uncommitted changes to $(UL "$local_hw") but --force was given; overwriting"
		fi
	fi

	# Check $update_hw_config again because we may have unset it above
	if [[ -n "$update_hw_config" ]]; then
		info "updating hardware-configuration.nix"
		cmd "nixos-generate-config --show-hardware-config > $(UL "\"$local_hw\"")"
		nixos-generate-config --show-hardware-config > "$local_hw"
	fi
fi

if [[ -h hardware-configuration.nix ]]; then
	dbg "$(UL hardware-configuration.nix) is already a symlink pointing to to $(UL "$(readlink hardware-configuration.nix)")"
elif [[ -f hardware-configuration.nix ]]; then
	if [[ -n "$hw_modified" ]] && [[ -z "$force_hw_config" ]] \
		&& ! diff --brief --new-file hardware-configuration.nix "$local_hw"; then
		warn "$(UL hardware-configuration.nix) already exists but there are uncommitted changes to $(UL "$local_hw") and the two files differ; refusing to overwrite without --force"
	else
		dbg "$(UL hardware-configuration.nix) already exists -- converting it to a symlink"
		cmd mv "$(UL hardware-configuration.nix)" "$(UL "$local_hw")"
		mv hardware-configuration.nix "$local_hw"
		info "creating a symlink at $(UL hardware-configuration.nix) pointing to $(UL "$local_hw")"
		ln -s "$local_hw" hardware-configuration.nix
	fi
elif [[ ! -e hardware-configuration.nix ]]; then
	if [[ "$(pwd)" == /etc/nixos ]]; then
		if [[ -e "$local_hw" ]]; then
			info "$(UL "$(pwd)/hardware-configuration.nix") doesn't exist in /etc/nixos"
			info "make sure to commit $(UL "$local_hw") to the repository"
		else
			info "$(UL "$(pwd)/hardware-configuration.nix") doesn't exist in /etc/nixos; generating now"
			cmd "sudo nixos-generate-config"
			sudo nixos-generate-config
			cmd mv "$(UL hardware-configuration.nix)" "$(UL "$local_hw")"
			mv hardware-configuration.nix "$local_hw"
		fi
		info "creating a symlink at $(UL hardware-configuration.nix) pointing to $(UL "$local_hw")"
		ln -s "$local_hw" hardware-configuration.nix
	elif [[ "$(uname -v)" = *NixOS* ]]; then
		info "creating a symlink at $(UL hardware-configuration.nix) pointing to $(UL "$local_hw")"
		ln -s "$local_hw" hardware-configuration.nix
	fi
fi
