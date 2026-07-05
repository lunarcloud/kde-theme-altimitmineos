#!/bin/bash

# Simplified converter: always use contents/sample_hack.theme and produce "ALTIMIT MINE OS"
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTENTS_DIR="$SCRIPT_DIR/contents"
INPUT_FILE="$CONTENTS_DIR/sample_hack.theme"
# filesystem-friendly ID for directories and filenames
THEME_ID="altimit_mine_os"
# Display name for the theme
THEME_NAME="ALTIMIT MINE OS"

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: File not found: $INPUT_FILE"
    exit 1
fi

# Create theme directory structure
THEME_DIR="$THEME_ID"
COLORS_DIR="$THEME_DIR/colors"
PLASMA_DIR="$THEME_DIR/plasmarc"

mkdir -p "$COLORS_DIR"
mkdir -p "$PLASMA_DIR"

echo "Converting $INPUT_FILE to Plasma 6 theme..."

# Helper: RGB -> hex
rgb_to_hex() {
    local r=$1 g=$2 b=$3
    printf "%02x%02x%02x" "$r" "$g" "$b"
}

# Read colors from Windows theme
declare -A colors
while IFS='=' read -r key value; do
    key=$(printf '%s' "$key" | xargs)
    value=$(printf '%s' "$value" | xargs)
    [[ -z "$key" || "$key" == \;* || "$key" == \#* ]] && continue
    if [[ "$value" =~ ^([0-9]+)[[:space:]]+([0-9]+)[[:space:]]+([0-9]+)$ ]]; then
        colors[$key]=$(rgb_to_hex "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}")
    fi
done < <(grep -A 100 "\\[Control Panel\\\\Colors\\]" "$INPUT_FILE" || true)

# Write colors file (template uses placeholders substituted below)
cat > "$COLORS_DIR/$THEME_ID.colors" << 'EOF'
[ColorScheme]
Name=ALTIMIT MINE OS
Comment=Desktop from .hack GU series

[Colors:Button]
BackgroundAlternate=efefef
BackgroundNormal=${ButtonFace}
DecorationFocus=3daee9
DecorationHover=93cee9
ForegroundActive=ffffff
ForegroundInactive=757575
ForegroundLink=2196f3
ForegroundNegative=f44336
ForegroundNeutral=ff9800
ForegroundNormal=${ButtonText}
ForegroundPositive=4caf50
ForegroundVisited=9c27b0

[Colors:Selection]
BackgroundAlternate=${Hilight}
BackgroundNormal=${Hilight}
DecorationFocus=${Hilight}
DecorationHover=${Hilight}
ForegroundActive=${HilightText}
ForegroundInactive=757575
ForegroundLink=2196f3
ForegroundNegative=f44336
ForegroundNeutral=ff9800
ForegroundNormal=${HilightText}
ForegroundPositive=4caf50
ForegroundVisited=9c27b0

[Colors:Tooltip]
BackgroundAlternate=${InfoWindow}
BackgroundNormal=${InfoWindow}
DecorationFocus=${InfoWindow}
DecorationHover=${InfoWindow}
ForegroundActive=${InfoText}
ForegroundInactive=757575
ForegroundLink=2196f3
ForegroundNegative=f44336
ForegroundNeutral=ff9800
ForegroundNormal=${InfoText}
ForegroundPositive=4caf50
ForegroundVisited=9c27b0

[Colors:View]
BackgroundAlternate=${Window}
BackgroundNormal=${Window}
DecorationFocus=${Hilight}
DecorationHover=93cee9
ForegroundActive=${Hilight}
ForegroundInactive=757575
ForegroundLink=2196f3
ForegroundNegative=f44336
ForegroundNeutral=ff9800
ForegroundNormal=${WindowText}
ForegroundPositive=4caf50
ForegroundVisited=9c27b0

[Colors:Window]
BackgroundAlternate=${Background}
BackgroundNormal=${Background}
DecorationFocus=${ActiveTitle}
DecorationHover=${ActiveTitle}
ForegroundActive=ffffff
ForegroundInactive=757575
ForegroundLink=2196f3
ForegroundNegative=f44336
ForegroundNeutral=ff9800
ForegroundNormal=${TitleText}
ForegroundPositive=4caf50
ForegroundVisited=9c27b0

[General]
ColorScheme=ALTIMIT MINE OS
EOF

# Substitute placeholders with hex values
for k in "${!colors[@]}"; do
    sed -i "s/\${$k}/#${colors[$k]}/g" "$COLORS_DIR/$THEME_ID.colors" || true
done

# Write metadata and desktop entry
PREVIEW_ICON="icons/square.png"
cat > "$THEME_DIR/metadata.json" << EOF
{
  "KPlugin": {
    "Id": "$THEME_ID",
    "Name": "ALTIMIT MINE OS",
    "Version": "1.0",
    "License": "Custom",
    "Authors": [{"Name":"Altimit","Email":""}],
    "Icon": "$PREVIEW_ICON",
    "ServiceTypes": ["Plasma/LookAndFeel"]
  },
  "Comment": "Desktop from .hack GU series",
  "colors": "colors/$THEME_ID.colors",
  "plasmarc": "plasmarc/plasmarc",
  "wallpapers": "wallpapers"
}
EOF

cat > "$THEME_DIR/metadata.desktop" << EOF
[Desktop Entry]
Name=ALTIMIT MINE OS
Comment=Desktop from .hack GU series
Type=Service
X-KDE-ServiceTypes=Plasma/LookAndFeel
Icon=$PREVIEW_ICON
EOF

# plasmarc
cat > "$PLASMA_DIR/plasmarc" << EOF
[General]
ColorScheme=${THEME_NAME}

[Theme]
name=${THEME_NAME}
EOF

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTENTS_DIR="$SCRIPT_DIR/contents"

copy_wallpaper() {
  mkdir -p "$THEME_DIR/wallpapers"
  if [[ -f "$CONTENTS_DIR/wallpaper_original.jpg" ]]; then
    cp -v "$CONTENTS_DIR/wallpaper_original.jpg" "$THEME_DIR/wallpapers/" || true
    echo "Image=wallpapers/wallpaper_original.jpg" >> "$PLASMA_DIR/plasmarc"
    return
  fi
  if [[ -f "$CONTENTS_DIR/wallpaper.jpg" ]]; then
    cp -v "$CONTENTS_DIR/wallpaper.jpg" "$THEME_DIR/wallpapers/" || true
    echo "Image=wallpapers/wallpaper.jpg" >> "$PLASMA_DIR/plasmarc"
    return
  fi
  local found
  found=$(find "$CONTENTS_DIR" -maxdepth 1 -type f -iregex '.*\.(jpg|jpeg|png|bmp)' 2>/dev/null | head -n1 || true)
  if [[ -n "$found" ]]; then
    cp -v "$found" "$THEME_DIR/wallpapers/" || true
    echo "Image=wallpapers/$(basename "$found")" >> "$PLASMA_DIR/plasmarc"
  fi
}

package_sounds() {
  SOUND_THEME_DIR="$THEME_DIR/sounds/$THEME_ID"
  mkdir -p "$SOUND_THEME_DIR/stereo"
  if [[ -d "$CONTENTS_DIR/Se" ]]; then
    find "$CONTENTS_DIR/Se" -type f \( -iname '*.ogg' -o -iname '*.mp3' -o -iname '*.wav' -o -iname '*.aif' \) -print0 | \
      while IFS= read -r -d '' sf; do
        cp -v "$sf" "$SOUND_THEME_DIR/stereo/" || true
      done
  fi
  cat > "$SOUND_THEME_DIR/index.theme" << EOF
[Sound Theme]
Name=ALTIMIT MINE OS
Comment=Desktop from .hack GU series
Directories=stereo
Example=theme-demo

[stereo]
OutputProfile=stereo
EOF
  if compgen -G "$SOUND_THEME_DIR/stereo/*" > /dev/null; then
    ls -1 "$SOUND_THEME_DIR/stereo/" > "$SOUND_THEME_DIR/FILES.txt"
  fi
}

copy_icons() {
  mkdir -p "$THEME_DIR/icons"
  if [[ -d "$CONTENTS_DIR/icon" ]]; then
    find "$CONTENTS_DIR/icon" -type f \( -iname '*.png' -o -iname '*.svg' \) -print0 | \
      while IFS= read -r -d '' ic; do
        cp -v "$ic" "$THEME_DIR/icons/" || true
      done
  fi
  if compgen -G "$THEME_DIR/icons/*" > /dev/null; then
    cat > "$THEME_DIR/icons/index.theme" << EOF
[Icon Theme]
Name=$THEME_NAME
Inherits=gnome,hicolor
Comment=Icons included with $THEME_NAME look-and-feel
Directories=16x16

[16x16]
Size=16
Context=Actions
Type=Fixed
EOF
  fi
}

write_readme() {
  cat > "$THEME_DIR/README.txt" << EOF
$THEME_NAME - ALTIMIT MINE OS (converted)

This package is self-contained and includes:
 - colors/         : KDE color scheme (.colors)
 - plasmarc/       : plasma configuration
 - wallpapers/     : wallpaper files
 - sounds/         : sound theme (sounds/$THEME_ID)
 - icons/          : icon files

Usage:
  ./theme_convert.sh           # creates "$THEME_ID/" and prompts to install
  ./theme_convert.sh --install # create and automatically install
  ./theme_convert.sh --no-install # create and skip installation

Manual install:
  mkdir -p ~/.local/share/plasma/look-and-feel/
  cp -r "$THEME_ID" ~/.local/share/plasma/look-and-feel/

To install the sound theme manually:
  mkdir -p ~/.local/share/sounds
  cp -r "$THEME_ID/sounds/$THEME_ID" ~/.local/share/sounds/

EOF
}

install_package() {
  DEST_BASE="$HOME/.local/share/plasma/look-and-feel"
  mkdir -p "$DEST_BASE"
  rm -rf "${DEST_BASE:?}/$THEME_ID"
  cp -r "$THEME_DIR" "$DEST_BASE/" 2>/dev/null || true
  INSTALL_DIR="$DEST_BASE/$THEME_ID"
  echo "✓ Theme installed (self-contained)!"
  echo "  Look-and-feel package: $INSTALL_DIR"
  echo "  README: $INSTALL_DIR/README.txt"
  if [[ -d "$THEME_DIR/sounds/$THEME_ID" ]]; then
    mkdir -p "$HOME/.local/share/sounds"
    rm -rf "$HOME/.local/share/sounds/$THEME_ID"
    cp -r "$THEME_DIR/sounds/$THEME_ID" "$HOME/.local/share/sounds/" 2>/dev/null || true
    echo "  Sound theme installed: $HOME/.local/share/sounds/$THEME_ID"
  fi
}

# Run actions
copy_wallpaper
package_sounds
copy_icons
write_readme

echo "✓ Theme structure created in: $THEME_DIR/"
echo "  - $COLORS_DIR/$THEME_ID.colors (color scheme)"
echo "  - $PLASMA_DIR/plasmarc (plasma configuration)"
echo "  - $THEME_DIR/metadata.json (metadata)"
echo "  - $THEME_DIR/README.txt (usage)"

# Parse flags: --install (auto), --no-install (skip), or prompt (default)
install_action="prompt"
for a in "$@"; do
  case "$a" in
    --install) install_action="yes" ;; 
    --no-install) install_action="no" ;; 
    install) install_action="yes" ;; 
    *) ;;
  esac
done

if [[ "$install_action" == "yes" ]]; then
  echo "Installing theme to $HOME/.local/share/plasma/look-and-feel/ ..."
  install_package
  echo "Done!"
  exit 0
elif [[ "$install_action" == "no" ]]; then
  echo "Skipping install. Theme files created in: $THEME_DIR/"
  echo "To install later, copy the package to: $HOME/.local/share/plasma/look-and-feel/"
  echo "Done!"
  exit 0
fi

# Interactive prompt (default)
read -p "Would you like to install this theme to ~/.local/share/plasma/look-and-feel/? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  install_package
  echo "Done!"
  exit 0
fi

echo "Theme files created in: $THEME_DIR/"
echo "To install, copy the package to: $HOME/.local/share/plasma/look-and-feel/"
echo "Done!"
