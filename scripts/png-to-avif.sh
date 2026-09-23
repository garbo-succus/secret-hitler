#!/usr/bin/env bash
# Resize original-resolution PNGs to 12 px/mm and encode AVIF at quality 0.7.
# Requires ImageMagick with AVIF support. Run from any working directory.
set -euo pipefail
shopt -s globstar nullglob

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source_root="$repo_root/src/raster"
output_root="$repo_root/dist/raster"
images=("$source_root"/**/*.png)

if (( ${#images[@]} == 0 )); then
  echo "No source PNGs found in $source_root" >&2
  exit 1
fi

for input in "${images[@]}"; do
  relative="${input#"$source_root/"}"
  output="$output_root/${relative%.png}.avif"
  case "$relative" in
    roles/*) size="756x1068!" ;;    # 63 × 89 mm
    offices/*) size="1920x586!" ;;  # 160 × 48.81 mm, rounded to whole pixels
    *) echo "Unknown physical size: $relative" >&2; exit 1 ;;
  esac
  mkdir -p -- "$(dirname -- "$output")"
  magick "$input" -resize "$size" -units PixelsPerInch -density 304.8 \
    -quality 70 -define heic:chroma=444 "$output"
done
