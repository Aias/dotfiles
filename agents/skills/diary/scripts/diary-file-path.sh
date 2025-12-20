#!/usr/bin/env bash
set -euo pipefail

mkdir -p ~/Code/vault/diary
TODAY=$(date +%Y-%m-%d)
DIARY_FILE=~/Code/vault/diary/${TODAY}.md
echo "Diary file: $DIARY_FILE"
