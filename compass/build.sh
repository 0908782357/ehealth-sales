#!/usr/bin/env bash
# Setzt index.html aus den Bausteinen in src/ zusammen und bettet alle Assets
# als data:-URIs ein, damit index.html eine einzige, portable Datei ist.
# Ausführen in Git Bash:  ./build.sh
set -e
cd "$(dirname "$0")"

cat src/part_head.html src/_input.js src/_quiz.js src/_alliance.js src/part_app.js src/part_tail.html > index.html

for f in assets/*.svg assets/*.png; do
  [ -e "$f" ] || continue
  name=$(basename "$f")
  case "$name" in
    *.svg) mime="image/svg+xml" ;;
    *.png) mime="image/png" ;;
    *)     continue ;;
  esac
  grep -q "assets/$name" index.html || continue
  b64=$(base64 -w0 "$f")
  sed -i "s|assets/$name|data:$mime;base64,$b64|g" index.html
done

echo "index.html gebaut: $(wc -c < index.html) Bytes, $(grep -c 'data:image' index.html) eingebettete Assets"
