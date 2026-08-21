#!/usr/bin/env bash
# Install Cursor engineering governance rules.
# Usage:
#   ./install.sh              # user-global (~/.cursor/rules)
#   ./install.sh --project    # current project (.cursor/rules)
#   ./install.sh /path/to/dir # custom destination rules dir

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC_RULE="$ROOT/.cursor/rules/engineering-governance.mdc"
SRC_MAP="$ROOT/templates/account-map.example.mdc"

if [[ ! -f "$SRC_RULE" ]]; then
  echo "error: missing $SRC_RULE" >&2
  exit 1
fi

DEST=""
COPY_MAP=0

case "${1:-}" in
  "" )
    DEST="${HOME}/.cursor/rules"
    ;;
  --project )
    DEST="$(pwd)/.cursor/rules"
    COPY_MAP=1
    ;;
  --help|-h )
    sed -n '2,7p' "$0"
    exit 0
    ;;
  * )
    DEST="$1"
    ;;
esac

mkdir -p "$DEST"
cp "$SRC_RULE" "$DEST/engineering-governance.mdc"
echo "installed: $DEST/engineering-governance.mdc"

if [[ "$COPY_MAP" -eq 1 ]]; then
  if [[ ! -f "$DEST/account-map.mdc" ]]; then
    cp "$SRC_MAP" "$DEST/account-map.mdc"
    echo "installed: $DEST/account-map.mdc  (edit YOUR_* placeholders)"
  else
    echo "skip: $DEST/account-map.mdc already exists"
  fi
fi

echo "done. Restart Cursor or start a new Agent chat so rules reload."
