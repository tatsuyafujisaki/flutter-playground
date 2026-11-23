#!/bin/bash
set -euo pipefail

# Copy the flavor-specific GoogleService-Info.plist into the app bundle.
SRC="${PROJECT_DIR:?PROJECT_DIR is not set}/Runner/Firebase/${FLAVOR:?FLAVOR is not set}/GoogleService-Info.plist"
DEST="${BUILT_PRODUCTS_DIR:?BUILT_PRODUCTS_DIR is not set}/${PRODUCT_NAME:?PRODUCT_NAME is not set}.app/GoogleService-Info.plist"

if [ ! -f "$SRC" ]; then
  echo "error: GoogleService-Info.plist not found at $SRC" >&2
  exit 1
fi

cp -f "$SRC" "$DEST"
echo "Copied $SRC to $DEST"
