#!/usr/bin/env bash
set -euo pipefail

# Lightweight repository-local Gradle launcher.
# It does NOT install GitHub Copilot. Copilot is expected to be already configured in IntelliJ.
GRADLE_VERSION="8.13"
DIST_NAME="gradle-${GRADLE_VERSION}-bin.zip"
DIST_URL="https://services.gradle.org/distributions/${DIST_NAME}"
CACHE_ROOT="${GRADLE_USER_HOME:-$HOME/.gradle}/wedding-wrapper/${GRADLE_VERSION}"
GRADLE_HOME="$CACHE_ROOT/gradle-${GRADLE_VERSION}"

if [[ ! -x "$GRADLE_HOME/bin/gradle" ]]; then
  mkdir -p "$CACHE_ROOT"
  ZIP="$CACHE_ROOT/$DIST_NAME"
  if [[ ! -f "$ZIP" ]]; then
    echo "[gradlew] Pobieram Gradle ${GRADLE_VERSION}..." >&2
    if command -v curl >/dev/null 2>&1; then
      curl --fail --location --retry 2 --output "$ZIP" "$DIST_URL"
    elif command -v wget >/dev/null 2>&1; then
      wget -O "$ZIP" "$DIST_URL"
    else
      echo "Brak curl/wget. Otwórz projekt w IntelliJ i użyj wbudowanej obsługi Gradle albo zainstaluj curl." >&2
      exit 1
    fi
  fi
  command -v unzip >/dev/null 2>&1 || { echo "Brak polecenia unzip." >&2; exit 1; }
  rm -rf "$GRADLE_HOME"
  unzip -q "$ZIP" -d "$CACHE_ROOT"
fi

exec "$GRADLE_HOME/bin/gradle" "$@"
