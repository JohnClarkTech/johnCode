#!/bin/bash
folder="/home/john/notes/pages"

for conflict in "$folder"/*.sync-conflict-*.md; do
  [ -e "$conflict" ] || continue  # skip if none found

  original="${conflict%.sync-conflict-*}.md"

  # If original missing, rename conflict as original
  if [ ! -f "$original" ]; then
    mv "$conflict" "$original"
    echo "Renamed $conflict to $original"
    continue
  fi

  # Compare modification times
  if [ "$conflict" -nt "$original" ]; then
    mv "$conflict" "$original"
    echo "Replaced $original with newer conflict $conflict"
  else
    rm "$conflict"
    echo "Removed older conflict $conflict"
  fi
done
