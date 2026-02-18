#!/usr/bin/env fish

argparse 'f/forces' 'v/verbose' 's/skip-update' -- $argv
or begin
    echo "Usage: (status filename) [-f|--forces] [-v|--verbose] [-s|--skip-update]" >&2
    exit 2
end

function die
    set_color red
    echo $argv >&2
    set_color normal
    exit 1
end

set -l verbose_args --quiet
if set -q _flag_verbose
    set verbose_args --verbose
end

clear

# Check uv version (before)
set -l uv_version (uv self version | string trim)

# IMPORTANT: declare in the outer scope
set -l uv_update_version ""

if set -q _flag_skip_update
    set_color yellow
    echo "Skipping uv update."
    set_color normal

    set uv_update_version $uv_version
else
    set_color green
    echo "Updating uv..."
    set_color normal

    uv self update $verbose_args
    or die "Error updating uv."

    echo
    set uv_update_version (uv self version | string trim)

    if not set -q _flag_forces; and test "$uv_version" = "$uv_update_version"
        set_color yellow
        echo "uv version was the same as before. Exiting."
        set_color normal
        echo
        exit 0
    end
end

# Now this will always work
set_color green
echo "uv version info:"
set_color normal
set_color yellow; echo "Old version: $uv_version"; set_color normal
set_color green;  echo "New version: $uv_update_version"; set_color normal

echo
set_color green
echo "Removing old packages in .venv folder..."
set_color normal
if test -d .venv
    set_color green; echo "Found .venv folder. Removing..."; set_color normal
    rm -rf .venv
    or die "Error removing .venv folder."
    set_color green; echo "Old packages removed."; set_color normal
else
    set_color yellow; echo "No .venv folder found."; set_color normal
end

echo
set_color green
echo "Removing uv.lock file"
set_color normal
if test -f uv.lock
    set_color green; echo "Found uv.lock file. Removing..."; set_color normal
    rm -f uv.lock
    or die "Error removing uv.lock."
    set_color green; echo "uv.lock file removed."; set_color normal
else
    set_color yellow; echo "No uv.lock file found."; set_color normal
end

echo
set_color green
echo "Installing new packages..."
set_color normal
uv sync --extra cu124
or die "Error installing new packages."
set_color green
echo "New packages installed."
set_color normal

echo
clear
uv self version

set_color green
echo "Running tests..."
set_color normal
uv run main.py
or die "Error running tests."

echo
# Copy package list to clipboard (best-effort)
set -l clip_cmd ""
if type -q wl-copy
    set clip_cmd "wl-copy"
else if type -q xclip
    set clip_cmd "xclip -selection clipboard"
else if type -q pbcopy
    set clip_cmd "pbcopy"
end

if test -n "$clip_cmd"
    uv pip list | sed 's/^/    /' | eval $clip_cmd
    and begin
        set_color green
        echo "Package list copied to clipboard."
        set_color normal
    end
else
    set_color yellow
    echo "No clipboard tool found (wl-copy/xclip/pbcopy). Skipping clipboard copy."
    set_color normal
end

set_color green
echo "Script completed."
set_color normal
