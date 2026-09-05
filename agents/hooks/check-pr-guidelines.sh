#!/usr/bin/env bash
exec python3 "$(dirname "$(readlink -f "$0")")/shell_commands.py" gh-pr
