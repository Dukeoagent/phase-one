#!/usr/bin/env bash
# Creates the GitHub repo (first run only), pushes source to main,
# and publishes build/web to the gh-pages branch for GitHub Pages.
set -euo pipefail
cd "$(dirname "$0")"
OWNER=Dukeoagent
REPO=phase-one
FLUTTER=/c/src/flutter/bin/flutter

tok=$(printf 'protocol=https\nhost=github.com\n' | git credential fill | grep '^password=' | cut -d= -f2-)
api() { curl -s -H "Authorization: token $tok" -H "Accept: application/vnd.github+json" "$@"; }

if [ "$(api -o /dev/null -w '%{http_code}' https://api.github.com/repos/$OWNER/$REPO)" = "404" ]; then
  echo "Creating repo $OWNER/$REPO"
  api -d "{\"name\":\"$REPO\",\"description\":\"Phase 1 Stabilization dashboard (Flutter web PWA)\",\"has_wiki\":false,\"has_projects\":false}" https://api.github.com/user/repos >/dev/null
fi
git remote get-url origin >/dev/null 2>&1 || git remote add origin https://github.com/$OWNER/$REPO.git
git push -u origin main

echo "Building"
MSYS_NO_PATHCONV=1 $FLUTTER build web --release --base-href "/$REPO/"
cp build/web/index.html build/web/404.html   # SPA fallback

echo "Publishing gh-pages"
tmp=$(mktemp -d)
cp -r build/web/. "$tmp"
( cd "$tmp" && git init -q -b gh-pages && git config user.name "$OWNER" && git config user.email "$OWNER@users.noreply.github.com" \
  && touch .nojekyll && git add -A && git commit -q -m "Deploy $(date -u +%Y-%m-%dT%H:%MZ)" \
  && git push -f -q https://github.com/$OWNER/$REPO.git gh-pages )
rm -rf "$tmp"

echo "Enabling Pages"
api -X POST -d '{"source":{"branch":"gh-pages","path":"/"}}' https://api.github.com/repos/$OWNER/$REPO/pages >/dev/null || true
api -X PUT -d '{"source":{"branch":"gh-pages","path":"/"}}' https://api.github.com/repos/$OWNER/$REPO/pages >/dev/null || true
echo "Live in a minute at: https://$OWNER.github.io/$REPO/"
