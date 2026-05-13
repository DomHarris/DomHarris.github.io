#!/usr/bin/env bash
# Generate small WebM loops and JPEG posters for nearly-birds gallery tiles.
# Requires: ffmpeg with libvpx-vp9 (typical Homebrew install).
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
  webm="$OUT/${base}.webm"
  poster="$OUT/${base}.poster.jpg"
  echo "==> $base"
  ffmpeg -hide_banner -loglevel error -y \
    -i "$f" -vf "scale=320:-2" -frames:v 1 -q:v 58 "$poster"
  ffmpeg -hide_banner -loglevel error -y \
    -loop 1 -i "$f" -t 1 -an -vf "scale=320:-2" \
    -c:v libvpx-vp9 -b:v 0 -crf 35 -row-mt 1 "$webm"
done

echo "Done. Output: $OUT"
