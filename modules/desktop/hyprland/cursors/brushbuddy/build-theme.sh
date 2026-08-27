#!/usr/bin/env bash
# Build the Brushbuddy Xcursor theme from extracted ANI frames.
# Runs inside a Nix derivation: $src is READ-ONLY; copy to a work dir first.
set -euo pipefail

WORK="$TMPDIR/brushbuddy-work"
mkdir -p "$WORK"
cp -r "$src/ani" "$src/extract.py" "$WORK/"

cd "$WORK"

# phase 1: extract PNG frames
mkdir -p frames
python3 extract.py

# phase 2: resize + xcursorgen per cursor
mkdir -p "$out/cursors"
SIZES="24 32 48 64 96 128 256"

# core | frame base | delay ms | hotspot at 256
CURSORS=(
  "default|Classic_cursor_Brushbuddy|120|36|19"
  "pointer|Link_pointer_Brushbuddy|180|116|16"
  "link|Link_pointer_Brushbuddy|180|116|16"
  "move|Move_Brushbuddy|90|120|210"
  "text|Text_hover_Brushbuddy|80|32|155"
  "progress|Loading_Brushbuddy|60|128|128"
  "wait|Loading_Brushbuddy|60|128|128"
  "ew-resize|Horizontal_resize_Brushbuddy|90|129|129"
  "ns-resize|Vertical_resize_Brushbuddy|90|129|129"
  "nesw-resize|Diagonal_resize_2_Brushbuddy|90|129|129"
  "nwse-resize|Diagonal_resize1_Brushbuddy|90|129|129"
)

for spec in "${CURSORS[@]}"; do
  IFS='|' read -r core frame delay hx hy <<< "$spec"
  for size in $SIZES; do
    mkdir -p "$WORK/work/$core/$size"
    for f in "$WORK/frames/${frame}"_f*.png; do
      name=$(basename "$f")
      convert "$f" -resize "${size}x${size}" "$WORK/work/$core/$size/$name"
    done
  done

  cfg="$WORK/work/$core/build.cursor"
  : > "$cfg"
  for size in $SIZES; do
    sx=$(( hx * size / 256 ))
    sy=$(( hy * size / 256 ))
    for f in "$WORK/work/$core/$size"/*.png; do
      echo "$size $sx $sy $f $delay" >> "$cfg"
    done
  done

  xcursorgen "$cfg" "$out/cursors/$core"
  echo "built $core"
done

# aliases
ln -sf default "$out/cursors/left_ptr"
ln -sf default "$out/cursors/arrow"
ln -sf default "$out/cursors/top_left_arrow"
ln -sf link "$out/cursors/hand2"
ln -sf link "$out/cursors/hand1"
ln -sf link "$out/cursors/pointing_hand"
ln -sf move "$out/cursors/fleur"
ln -sf text "$out/cursors/xterm"
ln -sf text "$out/cursors/ibeam"
ln -sf progress "$out/cursors/left_ptr_watch"
ln -sf progress "$out/cursors/watch"
ln -sf ew-resize "$out/cursors/sb_h_double_arrow"
ln -sf ew-resize "$out/cursors/h_double_arrow"
ln -sf ns-resize "$out/cursors/sb_v_double_arrow"
ln -sf ns-resize "$out/cursors/v_double_arrow"
ln -sf nwse-resize "$out/cursors/bottom_right_corner"
ln -sf nwse-resize "$out/cursors/top_left_corner"
ln -sf nesw-resize "$out/cursors/bottom_left_corner"
ln -sf nesw-resize "$out/cursors/top_right_corner"
# Hyprland 0.56.2 border-hover edge shapes (setCursorIconOnBorder):
# top_side/bottom_side/left_side/right_side — without these the edge
# resize cursor falls back to the plain arrow.
ln -sf ns-resize "$out/cursors/top_side"
ln -sf ns-resize "$out/cursors/bottom_side"
ln -sf ew-resize "$out/cursors/left_side"
ln -sf ew-resize "$out/cursors/right_side"

cat > "$out/index.theme" <<EOF
[Icon Theme]
Name=Brushbuddy
Comment=Animated Brushbuddy cursor pack
EOF
