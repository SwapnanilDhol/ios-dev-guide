#!/bin/bash
# Link the iOS Dev Guide into a host project so agents pick up AGENTS.md.
# Usage: ./scripts/link-guide.sh [/path/to/HostApp]
#
# By default links AGENTS.md + CLAUDE.md. Pass --pages to also symlink
# commonly consulted pages (optional; most agents only need AGENTS.md).

set -euo pipefail

LINK_PAGES=0
TARGET_DIR="."
for arg in "$@"; do
  case "$arg" in
    --pages) LINK_PAGES=1 ;;
    *) TARGET_DIR="$arg" ;;
  esac
done

ABS_TARGET="$(cd "$TARGET_DIR" && pwd)"
GUIDE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "Linking iOS Dev Guide into: $ABS_TARGET"
echo "Guide root: $GUIDE_DIR"

link_one() {
  local src="$1"
  local dest_name="$2"
  local dest="$ABS_TARGET/$dest_name"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "  skip (exists): $dest_name"
  else
    ln -s "$src" "$dest"
    echo "  linked: $dest_name -> $src"
  fi
}

link_one "$GUIDE_DIR/AGENTS.md" "AGENTS.md"
link_one "$GUIDE_DIR/CLAUDE.md" "CLAUDE.md"

if [ "$LINK_PAGES" -eq 1 ]; then
  link_one "$GUIDE_DIR/bootstrap/new-app-checklist.md" "new-app-checklist.md"
  link_one "$GUIDE_DIR/bootstrap/appdelegate-setup.md" "appdelegate-setup.md"
  link_one "$GUIDE_DIR/bootstrap/two-bundle-id.md" "two-bundle-id.md"
  link_one "$GUIDE_DIR/architecture/architecture.md" "architecture-guide.md"
  link_one "$GUIDE_DIR/architecture/concurrency.md" "concurrency.md"
  link_one "$GUIDE_DIR/stack/ads.md" "ads.md"
  link_one "$GUIDE_DIR/stack/analytics.md" "analytics.md"
  link_one "$GUIDE_DIR/stack/revenuecat.md" "revenuecat.md"
  link_one "$GUIDE_DIR/stack/sfk-first.md" "sfk-first.md"
  link_one "$GUIDE_DIR/product/onboarding.md" "onboarding-playbook.md"
  link_one "$GUIDE_DIR/ops/spm-debugging.md" "spm-debugging.md"
fi

# Optional: expose skills under .agents/skills when missing
if [ ! -e "$ABS_TARGET/.agents/skills" ] && [ ! -L "$ABS_TARGET/.agents/skills" ]; then
  mkdir -p "$ABS_TARGET/.agents"
  ln -s "$GUIDE_DIR/skills" "$ABS_TARGET/.agents/skills"
  echo "  linked: .agents/skills -> $GUIDE_DIR/skills"
else
  echo "  skip: .agents/skills already present (copy or merge skills manually if needed)"
fi

echo ""
echo "Done. Prefer a thin product overlay AGENTS.md in the host if you need app-specific deltas"
echo "(see templates/AGENTS.product-overlay.template.md). If you linked the kit AGENTS.md,"
echo "replace it with an overlay that points at: $GUIDE_DIR"
