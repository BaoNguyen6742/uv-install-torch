#!/usr/bin/env bash

set -u -o pipefail

forces=0
verbose=0
skip_update=0

# Support short + long options
while [[ $# -gt 0 ]]; do
    case "$1" in
    -f | --forces)
        forces=1
        shift
        ;;
    -v | --verbose)
        verbose=1
        shift
        ;;
    -s | --skip-update)
        skip_update=1
        shift
        ;;
    -h | --help)
        echo "Usage: $0 [-f|--forces] [-v|--verbose] [-s|--skip-update]"
        exit 0
        ;;
    *)
        echo "Unknown option: $1" >&2
        echo "Usage: $0 [-f|--forces] [-v|--verbose] [-s|--skip-update]" >&2
        exit 2
        ;;
    esac
done

green=$'\033[32m'
yellow=$'\033[33m'
red=$'\033[31m'
reset=$'\033[0m'

die() {
    echo "${red}$*${reset}" >&2
    exit 1
}

if ((verbose)); then
    verbose_args="--verbose"
else
    verbose_args="--quiet"
fi

clear

uv_version="$(uv self version | tr -d '\r\n')"

if ((skip_update)); then
    echo "${yellow}Skipping uv update.${reset}"
    uv_update_version="$uv_version"
else
    echo "${green}Updating uv...${reset}"
    uv self update "$verbose_args" || die "Error updating uv."

    echo
    uv_update_version="$(uv self version | tr -d '\r\n')"

    if ((!forces)) && [[ "$uv_version" == "$uv_update_version" ]]; then
        echo "${yellow}uv version was the same as before. Exiting.${reset}"
        echo
        exit 0
    fi
fi

echo "${green}uv version info:${reset}"
echo "${yellow}Old version: $uv_version${reset}"
echo "${green}New version: $uv_update_version${reset}"

echo
echo "${green}Removing old packages in .venv folder...${reset}"
if [[ -d ".venv" ]]; then
    echo "${green}Found .venv folder. Removing...${reset}"
    rm -rf .venv || die "Error removing .venv folder."
    echo "${green}Old packages removed.${reset}"
else
    echo "${yellow}No .venv folder found.${reset}"
fi

echo
echo "${green}Removing uv.lock file${reset}"
if [[ -f "uv.lock" ]]; then
    echo "${green}Found uv.lock file. Removing...${reset}"
    rm -f uv.lock || die "Error removing uv.lock."
    echo "${green}uv.lock file removed.${reset}"
else
    echo "${yellow}No uv.lock file found.${reset}"
fi

echo
echo "${green}Installing new packages...${reset}"
uv sync --extra cu124 || die "Error installing new packages."
echo "${green}New packages installed.${reset}"

echo
clear
uv self version

echo "${green}Running tests...${reset}"
uv run main.py || die "Error running tests."

echo
# Copy package list to clipboard (best-effort)
if command -v wl-copy >/dev/null 2>&1; then
    uv pip list | sed 's/^/    /' | wl-copy && echo "${green}Package list copied to clipboard.${reset}"
elif command -v xclip >/dev/null 2>&1; then
    uv pip list | sed 's/^/    /' | xclip -selection clipboard && echo "${green}Package list copied to clipboard.${reset}"
elif command -v pbcopy >/dev/null 2>&1; then
    uv pip list | sed 's/^/    /' | pbcopy && echo "${green}Package list copied to clipboard.${reset}"
else
    echo "${yellow}No clipboard tool found (wl-copy/xclip/pbcopy). Skipping clipboard copy.${reset}"
fi

echo "${green}Script completed.${reset}"
