#!/usr/bin/env bash
set -euo pipefail

if [ -f "rush.json" ]; then
  echo "rush.json detected. Run from a project directory with package.json:"
  echo "rush-pnpm outdated"
  exit 0
fi

if [ -f "bun.lock" ] || [ -f "bun.lockb" ]; then
  bun outdated
elif [ -f "pnpm-lock.yaml" ]; then
  pnpm outdated
elif [ -f "yarn.lock" ]; then
  yarn outdated
elif [ -f "package-lock.json" ]; then
  npm outdated
else
  echo "No recognized lock file found"
fi
