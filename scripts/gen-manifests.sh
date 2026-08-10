#!/bin/sh
# Regenerates assets/<folder>/manifest.json from the image files actually
# present in each gallery folder. Run automatically by the pre-commit hook;
# safe to run manually too. Handles filenames with spaces.
set -e

cd "$(dirname "$0")/.."

for dir in assets/mushrooms assets/nature; do
  manifest="$dir/manifest.json"
  tmplist="$(mktemp)"

  find "$dir" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \) \
    -exec basename {} \; \
    | sort > "$tmplist"

  {
    printf '['
    first=1
    while IFS= read -r name; do
      esc=$(printf '%s' "$name" | sed 's/\\/\\\\/g; s/"/\\"/g')
      if [ "$first" -eq 0 ]; then printf ','; fi
      printf '\n  "%s"' "$esc"
      first=0
    done < "$tmplist"
    if [ "$first" -eq 0 ]; then printf '\n'; fi
    printf ']\n'
  } > "$manifest"

  rm -f "$tmplist"
done
