#!/usr/bin/env bash
set -euo pipefail

# from https://manganiello.eu/objects/128bcc1b-8afc-4232-98e6-6aaaeeca5ab8
# Usage:
#   ./pkpass2png <pkpass_path_or_url> [output.png]
#
# Examples:
#   ./pkpass2png ticket.pkpass out.png
#   ./pkpass2png "https://example.com/ticket.pkpass" out.png

INPUT="${1:-}"
OUT="${2:-ticket.png}"

if [[ -z "$INPUT" ]]; then
  echo "Usage: $0 <pkpass_path_or_url> [output.png]" >&2
  exit 2
fi

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "Missing dependency: $1" >&2
        exit 2
    }
}

need_cmd jq
need_cmd zint
need_cmd magick
need_cmd unzip

# Pick a downloader if needed
is_url=0
if [[ "$INPUT" =~ ^https?:// ]]; then
  is_url=1
  if command -v curl >/dev/null 2>&1; then
    DL='curl -L --fail --silent --show-error'
  elif command -v wget >/dev/null 2>&1; then
    DL='wget -qO-'
  else
    echo "Need curl or wget to download URLs" >&2
    exit 2
  fi
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

PKPASS_FILE="$tmp/pass.pkpass"
EXTRACT_DIR="$tmp/extracted"
mkdir -p "$EXTRACT_DIR"

# ---- Acquire pkpass (download or copy) ----
if [[ "$is_url" -eq 1 ]]; then
  # download to file
  if [[ "$DL" == curl* ]]; then
    $DL "$INPUT" -o "$PKPASS_FILE"
  else
    $DL "$INPUT" > "$PKPASS_FILE"
  fi
else
  # local file
  if [[ ! -f "$INPUT" ]]; then
    echo "Input file not found: $INPUT" >&2
    exit 2
  fi
  cp -f "$INPUT" "$PKPASS_FILE"
fi

# ---- Extract pkpass (zip) ----
unzip -q "$PKPASS_FILE" -d "$EXTRACT_DIR"

PASS_JSON="$EXTRACT_DIR/pass.json"
if [[ ! -f "$PASS_JSON" ]]; then
  echo "pass.json not found inside pkpass" >&2
  exit 2
fi

# Choose base image: prefer strip.png if present, else background.png
if [[ -f "$EXTRACT_DIR/strip.png" ]]; then
  BASE_IMG="$EXTRACT_DIR/strip.png"
elif [[ -f "$EXTRACT_DIR/background.png" ]]; then
  BASE_IMG="$EXTRACT_DIR/background.png"
else
  echo "Neither strip.png nor background.png found in pkpass" >&2
  exit 2
fi

# Work files
MSG_FILE="$tmp/msg.txt"
BARCODE_RAW="$tmp/barcode_raw.png"
BARCODE_CARD="$tmp/barcode_card.png"
font="DejaVu-Sans"

# Find largest pointsize <= max_pt that fits within max_width pixels
fit_pt() {
  local text="$1" max_width="$2" max_pt="$3" font="$4"
  local pt w
  for ((pt=max_pt; pt>=9; pt--)); do
    w=$(magick -font "$font" -pointsize "$pt" \
      -background none label:"$text" -format '%w' info:)
    if [ "$w" -le "$max_width" ]; then
      echo "$pt"
      return
    fi
  done
  echo 9
}

# ---- Extract fields ----
org=$(jq -r '.organizationName // ""' "$PASS_JSON")
logoText=$(jq -r '.logoText // empty' "$PASS_JSON")
date=$(jq -r '.eventTicket.headerFields[]? | select(.key=="date") | .value' "$PASS_JSON" | head -n1)
event=$(jq -r '.eventTicket.primaryFields[]? | select(.key=="event") | .value' "$PASS_JSON" | head -n1)

loc_label=$(jq -r '.eventTicket.secondaryFields[]? | select(.key=="location") | .label' "$PASS_JSON" | head -n1)
loc_value=$(jq -r '.eventTicket.secondaryFields[]? | select(.key=="location") | .value' "$PASS_JSON" | head -n1)

seat_label=$(jq -r '.eventTicket.secondaryFields[]? | select(.key=="seat") | .label' "$PASS_JSON" | head -n1)
seat_value=$(jq -r '.eventTicket.secondaryFields[]? | select(.key=="seat") | .value' "$PASS_JSON" | head -n1)

price_label=$(jq -r '.eventTicket.auxiliaryFields[]? | select(.key=="price") | .label' "$PASS_JSON" | head -n1)
price_value=$(jq -r '.eventTicket.auxiliaryFields[]? | select(.key=="price") | .value' "$PASS_JSON" | head -n1)

alt_text=$(jq -r '.barcode.altText // ""' "$PASS_JSON")

fg=$(jq -r '.foregroundColor // "rgb(255,255,255)"' "$PASS_JSON")
label=$(jq -r '.labelColor // "rgb(200,200,200)"' "$PASS_JSON")

# ---- Canvas size ----
W=$(magick identify -format '%w' "$BASE_IMG")   # [1]
H=$(magick identify -format '%h' "$BASE_IMG")   # [1]

# ---- Proportional layout constants ----
# Margins/padding (percentages tuned to your 360x440 case)
M=$(( W * 4 / 100 ))                   # ~4% of width (360 -> 14)
[ "$M" -lt 10 ] && M=10

TOP=$(( H * 3 / 100 ))                 # ~3% of height (440 -> 13)
COL_GAP=$(( W * 4 / 100 ))             # ~4% of width
[ "$COL_GAP" -lt 10 ] && COL_GAP=10
COL_W=$(((W - 2*M - COL_GAP)/2))

# Barcode sizing derived from width
BC_SIZE=$(( W * 52 / 100 ))            # 360 -> 187
[ "$BC_SIZE" -lt 150 ] && BC_SIZE=150  # keep scannable
BOTTOM_MARGIN=$(( H * 4 / 100 ))        # 440 -> 17
[ "$BOTTOM_MARGIN" -lt 10 ] && BOTTOM_MARGIN=10
BAR_GAP=$(( H * 3 / 100 ))              # 440 -> 13
[ "$BAR_GAP" -lt 10 ] && BAR_GAP=10

# Font maxima (scale with height)
org_max=$(( H * 4 / 100 ))              # 440 -> 17
date_max=$(( H * 3 / 100 ))             # 440 -> 13
event_max=$(( H * 5 / 100 ))            # 440 -> 22
val_max=$(( H * 4 / 100 ))              # 440 -> 17
[ "$org_max" -lt 12 ] && org_max=12
[ "$date_max" -lt 11 ] && date_max=11
[ "$event_max" -lt 14 ] && event_max=14
[ "$val_max" -lt 12 ] && val_max=12

label_pt=$(( H * 3 / 100 ))             # 440 -> 13
[ "$label_pt" -lt 11 ] && label_pt=11

# Vertical gaps (scale with height)
gap1=$(( H * 7 / 100 ))                 # 440 -> 30
gap2=$(( H * 7 / 100 ))                 # 440 -> 30
gap3=$(( H * 4 / 100 ))                 # 440 -> 17
gap4=$(( H * 6 / 100 ))                 # 440 -> 22
gap5=$(( H * 4 / 100 ))                 # 440 -> 17

# Baseline clamp (prevents top clipping)
MIN_Y1=$(( H * 5 / 100 ))               # 440 -> 30
[ "$MIN_Y1" -lt 18 ] && MIN_Y1=18

# ---- Barcode (Aztec) ----
jq -r '.barcode.message' "$PASS_JSON" | iconv -f UTF-8 -t ISO-8859-1 > "$MSG_FILE"
zint --barcode=92 --scale=5 --border=1 -o "$BARCODE_RAW" -i "$MSG_FILE"  # [1]

magick "$BARCODE_RAW" \
  -resize "${BC_SIZE}x${BC_SIZE}" \
  -background white -gravity south -splice 0x$((H*5/100)) \
  -fill black -font "$font" -pointsize $((H*3/100)) \
  -annotate +0+0 "$alt_text" \
  -bordercolor white -border $((W*3/100)) \
  "$BARCODE_CARD"  # [1]

BAR_H=$(magick identify -format '%h' "$BARCODE_CARD")   # [1]
TEXT_H=$(( H - BAR_H - BOTTOM_MARGIN - BAR_GAP ))       # [1]

# ---- Auto-fit point sizes ----
# Leave room for date on the right: reserve ~40% width for it
org_pt=$(fit_pt "${logoText:-$org}" $((W - 2*M - (W*40/100))) "$org_max" "$font")  # [1]
date_pt=$(fit_pt "$date" $((W - 2*M)) "$date_max" "$font")                         # [1]
event_pt=$(fit_pt "$event" $((W - 2*M)) "$event_max" "$font")                      # [1]

loc_val_pt=$(fit_pt "$loc_value" "$COL_W" "$val_max" "$font")                      # [1]
seat_val_pt=$(fit_pt "$seat_value" "$COL_W" "$val_max" "$font")                    # [1]
price_val_pt=$(fit_pt "$price_value" $((W - 2*M)) "$val_max" "$font")              # [1]

# ---- Y positions ----
y1=$((TOP + (H*6/100)))     # org/date baseline
y2=$((y1 + gap1))           # event
y3=$((y2 + gap2))           # secondary labels
y4=$((y3 + gap3))           # secondary values
y5=$((y4 + gap4))           # price label
y6=$((y5 + gap5))           # price value

# Shift up if we collide with barcode reserved area (conservative)
max_y=$((y6 + (H*7/100)))
if [ "$max_y" -ge "$TEXT_H" ]; then
  shift=$((max_y - TEXT_H + (H*1/100)))
  y1=$((y1 - shift))
  y2=$((y2 - shift))
  y3=$((y3 - shift))
  y4=$((y4 - shift))
  y5=$((y5 - shift))
  y6=$((y6 - shift))
fi

# Clamp top baseline so first line doesn't clip
if [ "$y1" -lt "$MIN_Y1" ]; then
  d=$((MIN_Y1 - y1))
  y1=$((y1 + d))
  y2=$((y2 + d))
  y3=$((y3 + d))
  y4=$((y4 + d))
  y5=$((y5 + d))
  y6=$((y6 + d))
fi

# ---- Compose ----
magick "$BASE_IMG" \
  -font "$font" \
  \
  -gravity northwest \
  -fill "$fg" -pointsize "$org_pt" \
  -annotate +$M+$y1 "${logoText:-$org}" \
  \
  -gravity northeast \
  -fill "$fg" -pointsize "$date_pt" \
  -annotate +$M+$y1 "$date" \
  \
  -gravity northwest \
  -fill "$fg" -pointsize "$event_pt" \
  -annotate +$M+$y2 "$event" \
  \
  -fill "$fg" -pointsize "$label_pt" \
  -annotate +$M+$y3 "$loc_label" \
  \
  -gravity northeast \
  -fill "$fg" -pointsize "$label_pt" \
  -annotate +$M+$y3 "$seat_label" \
  \
  -gravity northwest \
  -fill "$label" -pointsize "$loc_val_pt" \
  -annotate +$M+$y4 "$loc_value" \
  \
  -gravity northeast \
  -fill "$label" -pointsize "$seat_val_pt" \
  -annotate +$M+$y4 "$seat_value" \
  \
  -gravity northwest \
  -fill "$fg" -pointsize "$label_pt" \
  -annotate +$M+$y5 "$price_label" \
  \
  -fill "$label" -pointsize "$price_val_pt" \
  -annotate +$M+$y6 "$price_value" \
  \
  \( "$BARCODE_CARD" \) \
  -gravity south -geometry +0+$BOTTOM_MARGIN -composite \
  \
  "$OUT"
