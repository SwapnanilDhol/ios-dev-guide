#!/bin/bash
# Link the iOS Dev Guide into the current project
# Usage: ~/Desktop/ios-dev-guide/link-guide.sh

TARGET_DIR="${1:-.}"
ABS_TARGET="$(cd "$TARGET_DIR" && pwd)"
GUIDE_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🔗 Linking iOS Dev Guide into: $ABS_TARGET"

# Link AGENTS.md
if [ -e "$ABS_TARGET/AGENTS.md" ] || [ -L "$ABS_TARGET/AGENTS.md" ]; then
    echo "  ⚠️  AGENTS.md already exists. Skipping."
else
    ln -s "$GUIDE_DIR/AGENTS.md" "$ABS_TARGET/AGENTS.md"
    echo "  ✅ AGENTS.md → $GUIDE_DIR/AGENTS.md"
fi

# Optional: also symlink common reference pages
for file in spm-debugging.md appdelegate-setup.md ads.md analytics.md architecture.md concurrency.md revenuecat.md update-available-banner.md code-snippets.md; do
    if [ -e "$ABS_TARGET/$file" ] || [ -L "$ABS_TARGET/$file" ]; then
        echo "  ⚠️  $file already exists. Skipping."
    else
        ln -s "$GUIDE_DIR/$file" "$ABS_TARGET/$file"
        echo "  ✅ $file → $GUIDE_DIR/$file"
    fi
done

echo ""
echo "Done. Agents working in this directory will now read AGENTS.md automatically."
