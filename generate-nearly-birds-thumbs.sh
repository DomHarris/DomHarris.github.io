#!/usr/bin/env bash
# Generate small WebP thumbnails for nearly-birds gallery tiles (still images).
# Requires: ffmpeg with libwebp (typical Homebrew install).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC="$ROOT/nearly-birds"
OUT="$SRC/thumbs"

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "error: ffmpeg not found in PATH" >&2
  exit 1
fi

mkdir -p "$OUT"
shopt -s nullglob
files=("$SRC"/*.jpg)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "error: no JPG files in $SRC" >&2
  exit 1
fi

for f in "${files[@]}"; do
  base=$(basename "$f" .jpg)
  webp="$OUT/${base}.webp"
  echo "==> $base"
  ffmpeg -hide_banner -loglevel error -y \
    -i "$f" -vf "scale=320:-2" \
    -c:v libwebp -quality 78 "$webp"
done

echo "Done. Output: $OUT"
