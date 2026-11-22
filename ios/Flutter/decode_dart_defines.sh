#!/bin/bash
set -euo pipefail

# Decode DART_DEFINES and write to DartDefines.xcconfig
OUTPUT_FILE="${SRCROOT:?SRCROOT is not set}/Flutter/DartDefines.xcconfig"
echo "// This is a generated file; do not edit or check into version control." > "$OUTPUT_FILE"

if [ -n "${DART_DEFINES:-}" ]; then
  echo "Decoding DART_DEFINES..."
  # Split by comma
  IFS=',' read -ra ADDR <<< "$DART_DEFINES"
  for item in "${ADDR[@]}"; do
    if [ -z "$item" ]; then
      continue
    fi
    # Decode base64
    DECODED=$(printf '%s' "$item" | base64 --decode)
    if [ -n "$DECODED" ]; then
      printf '%s\n' "$DECODED" >> "$OUTPUT_FILE"
      echo "  Decoded key: ${DECODED%%=*}"
    fi
  done
else
  echo "DART_DEFINES is empty."
fi
