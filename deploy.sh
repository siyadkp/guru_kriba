#!/usr/bin/env bash
# Builds the Guru Kripa website and uploads it to Cloudways.
#
#   ./deploy.sh
#
# Settings (override with environment variables):
#   CW_HOST   server IP                     (default 178.128.241.178)
#   CW_USER   SSH user                      (default master_zqpqahqrbk)
#   CW_PATH   web root on the server
#   CW_KEY    SSH private key file          (default ~/.ssh/distrotrack_cloudways)
#   CW_URL    live address checked at the end
#
# No passwords or keys are stored in this file.
set -euo pipefail
cd "$(dirname "$0")"

CW_HOST="${CW_HOST:-178.128.241.178}"
CW_USER="${CW_USER:-master_zqpqahqrbk}"
CW_PATH="${CW_PATH:-/home/master/applications/asxyrexmka/public_html}"
CW_KEY="${CW_KEY:-$HOME/.ssh/distrotrack_cloudways}"
CW_URL="${CW_URL:-http://phpstack-1650272-6776480.cloudwaysapps.com}"

echo "1/3  Building…"
# The rendering engine loads from Google's CDN (measured ~5x faster than
# serving it from Cloudways), so only the site itself is uploaded.
flutter build web --release --base-href /
tool/optimize_web.sh build/web

echo "2/3  Uploading to $CW_USER@$CW_HOST:$CW_PATH"
# --delete keeps the server an exact copy of the build. Debug symbol
# files are skipped: browsers never download them. Folder times and
# permissions are left alone: public_html belongs to the Cloudways app
# user, and the server's default permissions are already correct.
rsync -rltz --omit-dir-times --delete --delete-excluded --exclude '*.symbols' \
  --exclude 'canvaskit/' --exclude 'canvaskit-*/' \
  -e "ssh -i $CW_KEY -o IdentitiesOnly=yes" \
  build/web/ "$CW_USER@$CW_HOST:$CW_PATH/"

echo "3/3  Checking $CW_URL"
for path in / /about; do
  code=$(curl -s -o /dev/null -w '%{http_code}' "$CW_URL$path")
  echo "     $path → $code"
  [ "$code" = 200 ] || { echo "Unexpected status for $path" >&2; exit 1; }
done
echo "Done. The site is live at $CW_URL"
