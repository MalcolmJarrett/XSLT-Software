#!/bin/bash

# https://www.jetbrains.com/help/pycharm/configuring-line-endings-and-line-separators.html

set -u
set -e

for NAME in *.pptx
do

  OUTPUT="$NAME".txt

  echo $OUTPUT

  date > "$OUTPUT"
  echo "$NAME" >> "$OUTPUT"
  echo >> "$OUTPUT"

  python3 access-ppt/transform/doit.py \
    "$NAME" \
    | cut -d"," -f2- \
    >> "$OUTPUT"

done