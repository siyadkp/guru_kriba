#!/usr/bin/env bash
# Builds the website and pushes it to the GitHub repository that Cloudways
# deploys from ("Deployment via Git").
#
# First time:  DEPLOY_REPO=git@github.com:YOUR-USER/guru-kripa-website.git tool/publish_web.sh
# After that:  tool/publish_web.sh
# Then in Cloudways: Application → Deployment via Git → Pull.
set -euo pipefail
cd "$(dirname "$0")/.."

DEPLOY_DIR="${DEPLOY_DIR:-../guru_kripa_web_deploy}"
DEPLOY_REPO="${DEPLOY_REPO:-}"

flutter build web --release --no-web-resources-cdn

if [ ! -d "$DEPLOY_DIR/.git" ]; then
  if [ -z "$DEPLOY_REPO" ]; then
    echo "First run: set DEPLOY_REPO to the GitHub repository address." >&2
    exit 1
  fi
  mkdir -p "$DEPLOY_DIR"
  git -C "$DEPLOY_DIR" init -b main
  git -C "$DEPLOY_DIR" remote add origin "$DEPLOY_REPO"
fi

# Copy the built site; debug symbol files are never downloaded by browsers.
rsync -a --delete --exclude .git --exclude '*.symbols' build/web/ "$DEPLOY_DIR/"

git -C "$DEPLOY_DIR" add -A
if git -C "$DEPLOY_DIR" diff --cached --quiet; then
  echo "No changes to publish."
  exit 0
fi
git -C "$DEPLOY_DIR" commit -m "Publish website $(date '+%Y-%m-%d %H:%M')"
git -C "$DEPLOY_DIR" push -u origin main
echo "Pushed. Now in Cloudways: Application → Deployment via Git → Pull."
