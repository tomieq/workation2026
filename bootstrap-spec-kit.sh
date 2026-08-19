#!/usr/bin/env bash
set -euo pipefail
VERSION="v0.16.4"

echo "Preparing Spec Kit ${VERSION} for this repository..."
echo "GitHub Copilot is already expected to be configured in IntelliJ; this script does NOT install Copilot."

if ! command -v uv >/dev/null 2>&1; then
  echo "ERROR: uv is required to install the pinned Spec Kit CLI. Ask the organizer for the prepared environment." >&2
  exit 127
fi

uv tool install specify-cli --force --from "git+https://github.com/github/spec-kit.git@${VERSION}"
specify init --here --force --integration copilot --integration-options="--commands" --script sh
printf '
Spec Kit %s initialized. Return to Copilot Chat in IntelliJ and continue the Spec Kit workflow.
' "$VERSION"
