#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -ne 2 ]]; then
	echo "Usage: ./run.sh <input.json> <output.json>" >&2
	exit 64
fi

swift run --quiet workation2026 "$1" "$2"
