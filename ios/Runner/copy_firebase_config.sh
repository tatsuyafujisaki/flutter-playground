#!/bin/bash
set -euo pipefail

# Choose which GoogleService-Info.plist to use based on the build configuration (flavor)
# The configuration name usually contains the flavor name (e.g., Debug-dev, Release-prod)

DEST="${BUILT_PRODUCTS_DIR:?BUILT_PRODUCTS_DIR is not set}/${PRODUCT_NAME:?PRODUCT_NAME is not set}.app/GoogleService-Info.plist"

case "${CONFIGURATION:?CONFIGURATION is not set}" in
  *dev*|Debug)
    SRC="${PROJECT_DIR:?PROJECT_DIR is not set}/Runner/Firebase/dev/GoogleService-Info.plist"
    ;;
  *prod*|Release)
    SRC="${PROJECT_DIR:?PROJECT_DIR is not set}/Runner/Firebase/prod/GoogleService-Info.plist"
    ;;
  *)
    echo "error: No flavor detected in configuration: $CONFIGURATION" >&2
    exit 1
    ;;
esac

if [ ! -f "$SRC" ]; then
  echo "error: GoogleService-Info.plist not found at $SRC" >&2
  exit 1
fi

cp -f "$SRC" "$DEST"
echo "Copied $SRC to $DEST"
