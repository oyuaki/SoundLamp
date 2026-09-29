#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_dir=$(dirname "$script_dir")
design_dir="$repo_dir/Design"
assets_dir="$repo_dir/App/Assets.xcassets"
srgb_profile="/System/Library/ColorSync/Profiles/sRGB Profile.icc"
work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT HUP INT TERM

if ! command -v osascript >/dev/null 2>&1 || ! command -v sips >/dev/null 2>&1; then
  echo "error: osascript and sips are required (run this exporter on macOS)" >&2
  exit 1
fi
if [ ! -f "$srgb_profile" ]; then
  echo "error: macOS sRGB color profile was not found" >&2
  exit 1
fi

export_png() {
  source_svg=$1
  size=$2
  output_png=$3
  raw_png="$work_dir/render-${size}.png"

  osascript -l JavaScript "$script_dir/render-svg.js" "$source_svg" "$size" "$raw_png"
  sips -m "$srgb_profile" "$raw_png" --out "$output_png" >/dev/null

  actual_width=$(sips -g pixelWidth "$output_png" | awk '/pixelWidth:/ { print $2 }')
  actual_height=$(sips -g pixelHeight "$output_png" | awk '/pixelHeight:/ { print $2 }')
  if [ "$actual_width" != "$size" ] || [ "$actual_height" != "$size" ]; then
    echo "error: unexpected dimensions for $output_png: ${actual_width}x${actual_height}" >&2
    exit 1
  fi
}

silent_dir="$assets_dir/MenuIconSilent.imageset"
audible_dir="$assets_dir/MenuIconAudible.imageset"
app_dir="$assets_dir/AppIcon.appiconset"

export_png "$design_dir/MenuIconSilent.svg" 18 "$silent_dir/MenuIconSilent.png"
export_png "$design_dir/MenuIconSilent.svg" 36 "$silent_dir/MenuIconSilent@2x.png"
export_png "$design_dir/MenuIconAudible.svg" 18 "$audible_dir/MenuIconAudible.png"
export_png "$design_dir/MenuIconAudible.svg" 36 "$audible_dir/MenuIconAudible@2x.png"

export_png "$design_dir/AppIconSmall.svg" 16 "$app_dir/icon_16x16.png"
export_png "$design_dir/AppIconSmall.svg" 32 "$app_dir/icon_16x16@2x.png"
export_png "$design_dir/AppIconSmall.svg" 32 "$app_dir/icon_32x32.png"
export_png "$design_dir/AppIconSmall.svg" 64 "$app_dir/icon_32x32@2x.png"
export_png "$design_dir/AppIcon.svg" 128 "$app_dir/icon_128x128.png"
export_png "$design_dir/AppIcon.svg" 256 "$app_dir/icon_128x128@2x.png"
export_png "$design_dir/AppIcon.svg" 256 "$app_dir/icon_256x256.png"
export_png "$design_dir/AppIcon.svg" 512 "$app_dir/icon_256x256@2x.png"
export_png "$design_dir/AppIcon.svg" 512 "$app_dir/icon_512x512.png"
export_png "$design_dir/AppIcon.svg" 1024 "$app_dir/icon_512x512@2x.png"

echo "Exported SoundLamp icons to App/Assets.xcassets"
