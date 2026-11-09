#!/usr/bin/env bash
# Post-build optimisation for the Flutter web build. Run after
# `flutter build web` (deploy.sh and the GitHub workflow do this).
#
# 1. Cache busting — Cloudways' Nginx caches .js files for a year and
#    Flutter keeps the same file names in every build, so ?v=<timestamp>
#    is added to flutter_bootstrap.js and main.dart.js. A new deployment
#    is fetched at once; between deployments everything stays cached.
#    (The rendering engine comes from Google's CDN, whose address already
#    includes the engine version.)
# 2. Preloading — normally the browser discovers files one after another
#    (index.html → bootstrap → app code → font list → fonts), paying a
#    server round trip at each step. Preload hints in index.html start all
#    of them immediately, in parallel.
#
# Usage: tool/optimize_web.sh [build/web]
set -euo pipefail
dir="${1:-build/web}"
v="$(date -u +%Y%m%d%H%M%S)"

sed -i.bak "s|\"mainJsPath\":\"main.dart.js\"|\"mainJsPath\":\"main.dart.js?v=$v\"|" \
  "$dir/flutter_bootstrap.js"
sed -i.bak "s|src=\"flutter_bootstrap.js\"|src=\"flutter_bootstrap.js?v=$v\"|" \
  "$dir/index.html"
rm -f "$dir/flutter_bootstrap.js.bak" "$dir/index.html.bak"

python3 - "$dir" "$v" <<'PY'
import json
import sys
from pathlib import Path
from urllib.parse import quote

build, version = Path(sys.argv[1]), sys.argv[2]
links = [
    # The engine is fetched from Google's CDN: open that connection early.
    '<link rel="preconnect" href="https://www.gstatic.com" crossorigin>',
    f'<link rel="preload" href="main.dart.js?v={version}" as="script">',
    '<link rel="preload" href="assets/FontManifest.json" as="fetch" crossorigin>',
]
# Flutter downloads every font in the manifest before its first frame.
for family in json.loads((build / "assets/FontManifest.json").read_text()):
    for font in family["fonts"]:
        href = "assets/" + quote(font["asset"])
        links.append(f'<link rel="preload" href="{href}" as="fetch" crossorigin>')

index = build / "index.html"
html = index.read_text()
if "</head>" not in html:
    sys.exit("index.html has no </head>")
block = "  <!-- Added by tool/optimize_web.sh -->\n  " + "\n  ".join(links) + "\n"
index.write_text(html.replace("</head>", block + "</head>", 1))
print(f"Preloading {len(links) - 1} files")
PY

# Fail loudly if Flutter ever changes these files' format.
grep -q "main.dart.js?v=$v" "$dir/flutter_bootstrap.js"
grep -q "flutter_bootstrap.js?v=$v" "$dir/index.html"
echo "Cache-busting version: $v"
