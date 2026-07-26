#!/bin/bash
# Bootstrap a new host app with Docs stubs + product AGENTS overlay.
# Usage: ./scripts/bootstrap-new-app.sh /path/to/NewApp [--link]
#
# Copies templates into the host. With --link, also runs link-guide.sh
# (skills symlink). Does not overwrite existing AGENTS.md / Docs files.

set -euo pipefail

LINK=0
TARGET_DIR=""
for arg in "$@"; do
  case "$arg" in
    --link) LINK=1 ;;
    *) TARGET_DIR="$arg" ;;
  esac
done

if [ -z "$TARGET_DIR" ]; then
  echo "Usage: $0 /path/to/NewApp [--link]" >&2
  exit 1
fi

ABS_TARGET="$(mkdir -p "$TARGET_DIR" && cd "$TARGET_DIR" && pwd)"
GUIDE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "Bootstrapping host app at: $ABS_TARGET"
echo "Guide root: $GUIDE_DIR"

mkdir -p "$ABS_TARGET/Docs/modules"

copy_if_missing() {
  local src="$1"
  local dest="$2"
  if [ -e "$dest" ]; then
    echo "  skip (exists): $dest"
  else
    cp "$src" "$dest"
    echo "  wrote: $dest"
  fi
}

# Product overlay AGENTS — do not overwrite an existing one
if [ -e "$ABS_TARGET/AGENTS.md" ] || [ -L "$ABS_TARGET/AGENTS.md" ]; then
  echo "  skip (exists): AGENTS.md — edit manually to point at $GUIDE_DIR"
else
  sed "s|{{IOS_DEV_GUIDE_PATH}}|$GUIDE_DIR|g" \
    "$GUIDE_DIR/templates/AGENTS.product-overlay.template.md" \
    > "$ABS_TARGET/AGENTS.md"
  echo "  wrote: AGENTS.md (product overlay)"
fi

if [ -e "$ABS_TARGET/CLAUDE.md" ] || [ -L "$ABS_TARGET/CLAUDE.md" ]; then
  echo "  skip (exists): CLAUDE.md"
else
  cat > "$ABS_TARGET/CLAUDE.md" <<EOF
# CLAUDE.md

Follow the shared kit at \`$GUIDE_DIR\` (\`AGENTS.md\` / \`CLAUDE.md\` there).

This file holds **product-only** deltas for this app. Keep it short.
EOF
  echo "  wrote: CLAUDE.md (stub)"
fi

copy_if_missing \
  "$GUIDE_DIR/templates/Docs/architecture.template.md" \
  "$ABS_TARGET/Docs/architecture.md"

copy_if_missing \
  "$GUIDE_DIR/templates/Docs/modules/_MODULE.template.md" \
  "$ABS_TARGET/Docs/modules/_MODULE.template.md"

if [ "$LINK" -eq 1 ]; then
  "$GUIDE_DIR/scripts/link-guide.sh" "$ABS_TARGET" || true
fi

echo ""
echo "Next: open $GUIDE_DIR/bootstrap/new-app-checklist.md and walk the day-0 list."
