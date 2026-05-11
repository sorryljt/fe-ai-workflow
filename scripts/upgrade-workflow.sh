#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
  echo "Usage: $0 <version>" >&2
  echo "Example: $0 v0.2.0" >&2
  exit 1
fi

WORKFLOW_DIR=".workflow/fe-ai-workflow"

if [[ ! -d "$WORKFLOW_DIR" ]]; then
  echo "Error: $WORKFLOW_DIR not found. Run install first." >&2
  exit 1
fi

cd "$WORKFLOW_DIR"
git fetch
git checkout "$VERSION"
cd ../..

"$WORKFLOW_DIR/scripts/sync-workflow.sh" "$WORKFLOW_DIR" .

echo "✅ fe-ai-workflow upgraded to $VERSION"
echo ""
echo "Changes are ready. Commit when you're done:"
echo "  git add .workflow/fe-ai-workflow && git commit -m \"chore: upgrade fe-ai-workflow to $VERSION\""
