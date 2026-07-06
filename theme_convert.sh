#!/bin/bash

# Simplified converter: always use contents/sample_hack.theme and produce "ALTIMIT MINE OS"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTENTS_DIR="$SCRIPT_DIR/contents"
INPUT_FILE="$CONTENTS_DIR/sample_hack.theme"
# filesystem-friendly ID for directories and filenames
THEME_ID="altimit_mine_os"
# Display name for the theme
THEME_NAME="ALTIMIT MINE OS"
WALLPAPER_PACKAGE_ID="$THEME_ID"
WALLPAPER_PACKAGE_NAME="$THEME_NAME"

# Allow INTERFACE environment variable override (text/gui)
INTERFACE="${INTERFACE:-gui}"

# Only load GUI if interface is GUI
if [[ "$INTERFACE" != "text" ]]; then
  # shellcheck source=./script-dialog.sh
  pushd "$SCRIPT_DIR" || exit
  source "./script-dialog/script-dialog.sh"

  relaunch-if-not-visible

  # shellcheck disable=SC2034  # APP_NAME is used by script-dialog.sh functions
  APP_NAME="ALTIMIT MINE OS Theme Converter"
else
  pushd "$SCRIPT_DIR" || exit
fi

if [[ ! -f "$INPUT_FILE" ]]; then
    if [[ "$INTERFACE" == "text" ]]; then
      echo "Error: Input theme file not found: $INPUT_FILE" >&2
    else
      ACTIVITY="File Not Found"
      message-error "Input theme file not found: $INPUT_FILE"
    fi
    exit 1
fi

# Create theme directory structure
THEME_DIR="$THEME_ID"
COLORS_DIR="$THEME_DIR/colors"
PLASMA_DIR="$THEME_DIR/plasmarc"
WALLPAPER_PACKAGE_DIR="$THEME_DIR/wallpaper-package/$WALLPAPER_PACKAGE_ID"

mkdir -p "$COLORS_DIR"
mkdir -p "$PLASMA_DIR"
mkdir -p "$THEME_DIR/contents"

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

# Copy Breeze Light as base, then customize with extracted theme colors
if [[ -f /usr/share/color-schemes/BreezeLight.colors ]]; then
    cp /usr/share/color-schemes/BreezeLight.colors "$COLORS_DIR/$THEME_ID.colors"
    # Update the theme name
    sed -i "s/^Name=.*/Name=ALTIMIT MINE OS/" "$COLORS_DIR/$THEME_ID.colors"
    sed -i "s/^Comment=.*/Comment=Desktop from .hack GU series/" "$COLORS_DIR/$THEME_ID.colors"
    
    # Apply extracted theme colors (Windows RGB format) to override Breeze Light defaults
    # Map Windows color names to KDE color scheme entries
    declare -A color_map=(
        [ButtonFace]="252,252,252"
        [ButtonText]="35,38,41"
        [Window]="239,240,241"
        [WindowText]="35,38,41"
        [Hilight]="61,174,233"
        [HilightText]="252,252,252"
        [ActiveTitle]="61,174,233"
        [TitleText]="252,252,252"
        [InfoWindow]="255,250,188"
        [InfoText]="35,38,41"
    )
    
    # Override with extracted theme colors if available
    for win_color in "${!color_map[@]}"; do
        if [[ -n "${colors[$win_color]}" ]]; then
            # Convert hex to RGB format for KDE color scheme
            hex="${colors[$win_color]}"
            r=$((16#${hex:0:2}))
            g=$((16#${hex:2:2}))
            b=$((16#${hex:4:2}))
            
            # Apply to relevant KDE color groups
            case "$win_color" in
                ButtonFace|Window|InfoWindow)
                    sed -i "s/^BackgroundNormal=.*/BackgroundNormal=$r,$g,$b/" "$COLORS_DIR/$THEME_ID.colors"
                    ;;
                ButtonText|WindowText|InfoText)
                    sed -i "s/^ForegroundNormal=.*/ForegroundNormal=$r,$g,$b/" "$COLORS_DIR/$THEME_ID.colors"
                    ;;
                Hilight|ActiveTitle)
                    sed -i "s/^DecorationFocus=.*/DecorationFocus=$r,$g,$b/" "$COLORS_DIR/$THEME_ID.colors"
                    ;;
                HilightText|TitleText)
                    sed -i "s/^ForegroundActive=.*/ForegroundActive=$r,$g,$b/" "$COLORS_DIR/$THEME_ID.colors"
                    ;;
            esac
        fi
    done
else
  # Fallback if Breeze Light is not found
  cat > "$COLORS_DIR/$THEME_ID.colors" << 'EOF'
[ColorScheme]
Name=ALTIMIT MINE OS
Comment=Desktop from .hack GU series

[Colors:Button]
BackgroundAlternate=a3d4fa
BackgroundNormal=fcfcfc
DecorationFocus=3daee9
DecorationHover=3daee9
ForegroundActive=3daee9
ForegroundInactive=707d8a
ForegroundLink=2980b9
ForegroundNegative=da4453
ForegroundNeutral=f67400
ForegroundNormal=232629
ForegroundPositive=27ae60
ForegroundVisited=9b59b6

[Colors:Selection]
BackgroundAlternate=a3d4fa
BackgroundNormal=a3d4fa
DecorationFocus=3daee9
DecorationHover=3daee9
ForegroundActive=3daee9
ForegroundInactive=707d8a
ForegroundLink=2980b9
ForegroundNegative=da4453
ForegroundNeutral=f67400
ForegroundNormal=fcfcfc
ForegroundPositive=27ae60
ForegroundVisited=9b59b6

[Colors:Tooltip]
BackgroundAlternate=fffabc
BackgroundNormal=fffabc
DecorationFocus=3daee9
DecorationHover=3daee9
ForegroundActive=3daee9
ForegroundInactive=707d8a
ForegroundLink=2980b9
ForegroundNegative=da4453
ForegroundNeutral=f67400
ForegroundNormal=232629
ForegroundPositive=27ae60
ForegroundVisited=9b59b6

[Colors:View]
BackgroundAlternate=f7f7f7
BackgroundNormal=fcfcfc
DecorationFocus=a3d4fa
DecorationHover=e8f4f8
ForegroundActive=3daee9
ForegroundInactive=707d8a
ForegroundLink=2980b9
ForegroundNegative=da4453
ForegroundNeutral=f67400
ForegroundNormal=232629
ForegroundPositive=27ae60
ForegroundVisited=9b59b6

[Colors:Window]
BackgroundAlternate=eff0f1
BackgroundNormal=eff0f1
DecorationFocus=3daee9
DecorationHover=3daee9
ForegroundActive=3daee9
ForegroundInactive=707d8a
ForegroundLink=2980b9
ForegroundNegative=da4453
ForegroundNeutral=f67400
ForegroundNormal=232629
ForegroundPositive=27ae60
ForegroundVisited=9b59b6

[General]
ColorScheme=ALTIMIT MINE OS
EOF
fi

# Substitute placeholders with hex values
for k in "${!colors[@]}"; do
    sed -i "s/\${$k}/#${colors[$k]}/g" "$COLORS_DIR/$THEME_ID.colors" || true
done

# Find and copy wallpaper first
find_and_copy_wallpaper() {
  mkdir -p "$THEME_DIR/wallpapers"
  if [[ -f "$CONTENTS_DIR/wallpaper_original.jpg" ]]; then
    cp -v "$CONTENTS_DIR/wallpaper_original.jpg" "$THEME_DIR/wallpapers/" > /dev/null 2>&1 || true
    echo "wallpapers/wallpaper_original.jpg"
    return
  fi
  if [[ -f "$CONTENTS_DIR/wallpaper.jpg" ]]; then
    cp -v "$CONTENTS_DIR/wallpaper.jpg" "$THEME_DIR/wallpapers/" > /dev/null 2>&1 || true
    echo "wallpapers/wallpaper.jpg"
    return
  fi
  local found
  found=$(find "$CONTENTS_DIR" -maxdepth 1 -type f -iregex '.*\.(jpg|jpeg|png|bmp)' 2>/dev/null | head -n1 || true)
  if [[ -n "$found" ]]; then
    cp -v "$found" "$THEME_DIR/wallpapers/" > /dev/null 2>&1 || true
    echo "wallpapers/$(basename "$found")"
    return
  fi
}

find_and_copy_wallpaper > /dev/null

# Use square logo for icon
PREVIEW_ICON="icons/square.png"

# Write metadata and desktop entry
cat > "$THEME_DIR/metadata.json" << EOF
{
  "KPackageStructure": "Plasma/LookAndFeel",
  "KPlugin": {
    "Id": "$THEME_ID",
    "Name": "ALTIMIT MINE OS",
    "Version": "1.0",
    "License": "Custom",
    "Authors": [{"Name":"Altimit","Email":""}],
    "Icon": "$PREVIEW_ICON",
    "ServiceTypes": ["Plasma/LookAndFeel"],
    "EnabledByDefault": false
  },
  "Comment": "Desktop from .hack GU series",
  "colors": "colors/$THEME_ID.colors",
  "icons": "$THEME_ID",
  "plasmarc": "plasmarc/plasmarc",
  "wallpapers": "wallpapers",
  "X-Plasma-MainScript": "defaults",
  "X-Plasma-APIVersion": "2"
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

# Create contents/defaults file (required by Plasma/LookAndFeel packages)
cat > "$THEME_DIR/contents/defaults" << EOF
[Cursors]
Theme=breeze_cursors

[General]
ColorScheme=${THEME_NAME}

[Icons]
Theme=${THEME_ID}

[Sounds]
Theme=${THEME_ID}

[kdeglobals]
ColorScheme=${THEME_NAME}
EOF

copy_wallpaper() {
  # Wallpaper already copied by find_and_copy_wallpaper()
  # Just add Image path to plasmarc
  if [[ -f "$THEME_DIR/wallpapers/wallpaper_original.jpg" ]]; then
    echo "Image=wallpapers/wallpaper_original.jpg" >> "$PLASMA_DIR/plasmarc"
    wallpaper_file="$THEME_DIR/wallpapers/wallpaper_original.jpg"
  elif [[ -f "$THEME_DIR/wallpapers/wallpaper.jpg" ]]; then
    echo "Image=wallpapers/wallpaper.jpg" >> "$PLASMA_DIR/plasmarc"
    wallpaper_file="$THEME_DIR/wallpapers/wallpaper.jpg"
  elif compgen -G "$THEME_DIR/wallpapers/*" > /dev/null 2>&1; then
    local wallpaper
    wallpaper=$(find "$THEME_DIR/wallpapers" -maxdepth 1 -type f | head -1)
    if [[ -n "$wallpaper" ]]; then
      echo "Image=wallpapers/$(basename "$wallpaper")" >> "$PLASMA_DIR/plasmarc"
      wallpaper_file="$wallpaper"
    fi
  fi
  
  # Create preview images for KDE System Settings
  if [[ -n "$wallpaper_file" && -f "$wallpaper_file" ]]; then
    mkdir -p "$THEME_DIR/contents/previews"
    
    # Create preview.png (thumbnail, ~1400x1100)
    if command -v convert &> /dev/null; then
      convert "$wallpaper_file" -resize 1400x1100 "$THEME_DIR/contents/previews/preview.png" 2>/dev/null || true
      # Create fullscreenpreview.jpg (full resolution)
      convert "$wallpaper_file" -quality 90 "$THEME_DIR/contents/previews/fullscreenpreview.jpg" 2>/dev/null || true
    else
      # Fallback: just copy wallpaper if convert not available
      cp "$wallpaper_file" "$THEME_DIR/contents/previews/preview.png" 2>/dev/null || true
      cp "$wallpaper_file" "$THEME_DIR/contents/previews/fullscreenpreview.jpg" 2>/dev/null || true
    fi
    
    # Create splash screen from wallpaper
    mkdir -p "$THEME_DIR/contents/splash/images"
    
    # Copy wallpaper as splash background
    cp "$wallpaper_file" "$THEME_DIR/contents/splash/images/background.jpeg" 2>/dev/null || true
    
    # Create splash animation (use square icon, scale to 128x128)
    if command -v convert &> /dev/null; then
      if [[ -f "$CONTENTS_DIR/icon/square.png" ]]; then
        convert "$CONTENTS_DIR/icon/square.png" -resize 128x128 "$THEME_DIR/contents/splash/images/animation01.png" 2>/dev/null || true
      fi
    fi
    
    # Create Splash.qml
    cat > "$THEME_DIR/contents/splash/Splash.qml" << 'SPLASHEOF'
import QtQuick
import org.kde.kirigami 2 as Kirigami

Rectangle {
    id: root
    color: "#000000"

    property int stage

    onStageChanged: {
        if (stage == 1) {
            fadeInOutAnimation.running = true
        }
    }

    Item {
        id: content
        anchors.fill: parent
        opacity: 1.0
        
        TextMetrics {
            id: units
            text: "M"
            property int gridUnit: boundingRect.height
            property int largeSpacing: units.gridUnit
            property int smallSpacing: Math.max(2, gridUnit/4)
        }

        Image {
            id: bg
            anchors.fill: parent
            source: "images/background.jpeg"
            sourceSize.width: root.width
            sourceSize.height: root.height
            fillMode: Image.PreserveAspectCrop
        }

        Image {
            id: animation
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: parent.height / 6
            sourceSize.height: 128
            sourceSize.width: 128
            source: "images/animation01.png"
            opacity: 0
            
            SequentialAnimation {
                id: fadeInOutAnimation
                running: false
                loops: Animation.Infinite
                
                OpacityAnimator {
                    target: animation
                    from: 0
                    to: 1
                    duration: 800
                }
                
                PauseAnimation {
                    duration: 400
                }
                
                OpacityAnimator {
                    target: animation
                    from: 1
                    to: 0
                    duration: 800
                }
                
                PauseAnimation {
                    duration: 400
                }
            }
        }
    }
}
SPLASHEOF
  fi
}

package_wallpaper_for_kde() {
  [[ -n "$wallpaper_file" && -f "$wallpaper_file" ]] || return

  local wallpaper_ext images_dir screenshot_file
  wallpaper_ext="${wallpaper_file##*.}"
  images_dir="$WALLPAPER_PACKAGE_DIR/contents/images"

  mkdir -p "$images_dir"

  cat > "$WALLPAPER_PACKAGE_DIR/metadata.json" << EOF
{
  "KPlugin": {
    "Id": "$WALLPAPER_PACKAGE_ID",
    "Name": "$WALLPAPER_PACKAGE_NAME",
    "Version": "1.0",
    "License": "Custom",
    "Authors": [{"Name":"Altimit","Email":""}]
  }
}
EOF

  if command -v convert &> /dev/null; then
    if ! convert "$wallpaper_file" -filter Lanczos -resize 1920x1080^ -gravity center -extent 1920x1080 "$images_dir/1920x1080.jpg" 2>/dev/null; then
      cp "$wallpaper_file" "$images_dir/original.$wallpaper_ext"
    fi

    screenshot_file="$WALLPAPER_PACKAGE_DIR/contents/screenshot.jpg"
    if ! convert "$wallpaper_file" -filter Lanczos -resize 512x320^ -gravity center -extent 512x320 "$screenshot_file" 2>/dev/null; then
      cp "$wallpaper_file" "$WALLPAPER_PACKAGE_DIR/contents/screenshot.$wallpaper_ext"
    fi
  else
    cp "$wallpaper_file" "$images_dir/original.$wallpaper_ext"
    cp "$wallpaper_file" "$WALLPAPER_PACKAGE_DIR/contents/screenshot.$wallpaper_ext"
  fi
}

package_sounds() {
  SOUND_THEME_DIR="$THEME_DIR/sounds/$THEME_ID"
  mkdir -p "$SOUND_THEME_DIR/stereo"
  
  # Map .hack sounds to KDE standard sound event names
  declare -A sound_map=(
    # Login/Startup
    [top_login]="service-login"
    [top_startOS]="system-startup"
    
    # Menu/UI Navigation
    [menu_open]="dialog-open"
    [menu_close]="dialog-close"
    [top_slct1]="dialog-positive"
    [top_slct2]="dialog-positive"
    [top_scroll1]="screen-scroll"
    [top_scroll2]="screen-scroll"
    [menu_pageSlct]="complete"
    [top_pageSlct]="complete"
    
    # UI Actions
    [menu_slct]="activate"
    [skil_heal]="complete"
    [top_fix1]="dialog-positive"
    [top_fix2]="dialog-positive"
    [menu_fix]="dialog-positive"
    
    # System Events
    [top_newmail]="message-new-instant"
    [shortmail]="message-new-instant"
    [top_cancel]="dialog-cancel"
    [chainsaw]="alarm-clock-elapsed"
    [wispOn]="device-added"
    [wispOff]="device-removed"
  )
  
  # Copy all sound files first
  if [[ -d "$CONTENTS_DIR/Se" ]]; then
    find "$CONTENTS_DIR/Se" -type f \( -iname '*.ogg' -o -iname '*.mp3' -o -iname '*.wav' -o -iname '*.aif' \) -print0 | \
      while IFS= read -r -d '' sf; do
        cp -v "$sf" "$SOUND_THEME_DIR/stereo/" > /dev/null 2>&1 || true
      done
  fi
  
  # Create symlinks to KDE standard sound event names
  for src_base in "${!sound_map[@]}"; do
    dest_name="${sound_map[$src_base]}"
    # Find source file with any extension
    src_file=$(find "$SOUND_THEME_DIR/stereo" -maxdepth 1 -iname "${src_base}.*" -type f | head -1)
    if [[ -f "$src_file" ]]; then
      ext="${src_file##*.}"
      dest_file="$SOUND_THEME_DIR/stereo/${dest_name}.${ext}"
      # Create symlink if it doesn't already exist
      if [[ ! -e "$dest_file" ]]; then
        ln -s "$(basename "$src_file")" "$dest_file" 2>/dev/null || true
      fi
    fi
  done
  
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
  mkdir -p "$THEME_DIR/icons/48x48/apps"
  
  # Map custom icons to standard KDE icon names
  declare -A icon_map=(
    [yomoyama]="application-internet"
    [the_world]="steam"
    [square]="application-x-executable"
    [news_capture]="application-rss+xml"
    [media_performer]="vlc"
    [mail_station]="evolution"
    [data_manager]="system-file-manager"
    [accessories]="preferences-system"
  )
  
  if [[ -d "$CONTENTS_DIR/icon" ]]; then
    for base in "${!icon_map[@]}"; do
      icon_file=$(find "$CONTENTS_DIR/icon" -maxdepth 1 -iname "${base}.*" -type f | head -1)
      if [[ -f "$icon_file" ]]; then
        ext="${icon_file##*.}"
        target_name="${icon_map[$base]}.$ext"
        cp -v "$icon_file" "$THEME_DIR/icons/48x48/apps/$target_name" > /dev/null 2>&1 || true
      fi
    done
  fi
  
  if compgen -G "$THEME_DIR/icons/48x48/apps/*" > /dev/null; then
    # Determine icon theme inheritance based on what's available
    local inherits="breeze,gnome,hicolor"
    if [[ -d /usr/share/icons/Yaru ]]; then
      inherits="Yaru,breeze,gnome,hicolor"
    elif [[ -d /usr/share/icons/Adwaita ]]; then
      inherits="Adwaita,breeze,gnome,hicolor"
    fi
    
    cat > "$THEME_DIR/icons/index.theme" << EOF
[Icon Theme]
Name=$THEME_NAME
Inherits=$inherits
Comment=Icons included with $THEME_NAME look-and-feel (extends system theme)
Directories=48x48/apps

[48x48/apps]
Size=48
Context=Applications
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
 - wallpaper-package/: KDE wallpaper package
 - sounds/         : sound theme (sounds/$THEME_ID)
 - icons/          : icon files

Usage:
  ./theme_convert.sh           # creates "$THEME_ID/" and prompts to install
  ./theme_convert.sh --install # create and automatically install
  ./theme_convert.sh --no-install # create and skip installation

Manual install:
  mkdir -p ~/.local/share/plasma/look-and-feel/
  cp -r "$THEME_ID" ~/.local/share/plasma/look-and-feel/

To install the wallpaper manually:
  mkdir -p ~/.local/share/wallpapers/
  cp -r "$THEME_ID/wallpaper-package/$WALLPAPER_PACKAGE_ID" ~/.local/share/wallpapers/

To install the sound theme manually:
  mkdir -p ~/.local/share/sounds
  cp -r "$THEME_ID/sounds/$THEME_ID" ~/.local/share/sounds/

EOF
}

install_package() {
  DEST_BASE="$HOME/.local/share/plasma/look-and-feel"
  mkdir -p "$DEST_BASE"
  rm -rf "${DEST_BASE:?}/$THEME_ID" 2>/dev/null || true
  cp -r "$THEME_DIR" "$DEST_BASE/" 2>/dev/null || true
  # shellcheck disable=SC2034  # INSTALL_DIR is used by script-dialog.sh functions
  INSTALL_DIR="$DEST_BASE/$THEME_ID"
  if [[ -d "$THEME_DIR/sounds/$THEME_ID" ]]; then
    mkdir -p "$HOME/.local/share/sounds"
    rm -rf "$HOME/.local/share/sounds/$THEME_ID" 2>/dev/null || true
    cp -r "$THEME_DIR/sounds/$THEME_ID" "$HOME/.local/share/sounds/" 2>/dev/null || true
  fi
  
  # Install color scheme separately (required for KDE to recognize it)
  if [[ -f "$THEME_DIR/colors/$THEME_ID.colors" ]]; then
    mkdir -p "$HOME/.local/share/color-schemes"
    cp "$THEME_DIR/colors/$THEME_ID.colors" "$HOME/.local/share/color-schemes/" 2>/dev/null || true
  fi
  
  # Install icon theme separately (required for KDE to recognize it)
  if [[ -d "$THEME_DIR/icons" ]] && [[ -f "$THEME_DIR/icons/index.theme" ]]; then
    mkdir -p "$HOME/.local/share/icons"
    rm -rf "$HOME/.local/share/icons/$THEME_ID" 2>/dev/null || true
    cp -r "$THEME_DIR/icons" "$HOME/.local/share/icons/$THEME_ID" 2>/dev/null || true
  fi

  # Install wallpaper package separately so it appears in KDE Wallpaper settings
  if [[ -d "$WALLPAPER_PACKAGE_DIR" ]] && [[ -f "$WALLPAPER_PACKAGE_DIR/metadata.json" ]]; then
    mkdir -p "$HOME/.local/share/wallpapers"
    rm -rf "$HOME/.local/share/wallpapers/$WALLPAPER_PACKAGE_ID" 2>/dev/null || true
    cp -r "$WALLPAPER_PACKAGE_DIR" "$HOME/.local/share/wallpapers/" 2>/dev/null || true
  fi
}

# shellcheck disable=SC2034  # ACTIVITY is used by script-dialog.sh functions
if [[ "$INTERFACE" == "text" ]]; then
  echo "Packaging theme..." >&2
else
  ACTIVITY="Packaging theme..."
fi

if [[ "$INTERFACE" == "text" ]]; then
  copy_wallpaper
  package_wallpaper_for_kde
  package_sounds
  copy_icons
  write_readme
  echo "Done" >&2
else
  {
    progressbar_update 1
    copy_wallpaper
    package_wallpaper_for_kde
    progressbar_update 33
    package_sounds
    progressbar_update 66
    copy_icons
    progressbar_update 85
    write_readme
    progressbar_update 100
    progressbar_finish
  } | progressbar
fi

# Parse command-line arguments
install_action="prompt"
for arg in "$@"; do
  case "$arg" in
    --install) install_action="yes" ;;
    --no-install) install_action="no" ;;
    *) ;;
  esac
done

# Handle installation based on action
if [[ "$install_action" == "yes" ]]; then
  install_package
  if [[ "$INTERFACE" == "text" ]]; then
    echo "Theme installed successfully to ~/.local/share/plasma/look-and-feel/" >&2
  else
    message-info "Theme installed successfully to ~/.local/share/plasma/look-and-feel/"
  fi
  exit 0
elif [[ "$install_action" == "no" ]]; then
  if [[ "$INTERFACE" == "text" ]]; then
    echo "Theme package created in: $THEME_DIR/" >&2
  else
    message-info "Theme package created in: $THEME_DIR/"
  fi
  exit 0
else
  # Prompt user to install
  if [[ "$INTERFACE" == "text" ]]; then
    read -p "Install theme to ~/.local/share/plasma/look-and-feel/? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      install_package
      echo "Theme installed successfully to ~/.local/share/plasma/look-and-feel/" >&2
    else
      echo "Theme package created in: $THEME_DIR/" >&2
    fi
  else
    if yesno "Would you like to install this theme to ~/.local/share/plasma/look-and-feel/?"; then
      install_package
      message-info "Theme installed successfully to ~/.local/share/plasma/look-and-feel/"
    else
      message-info "Theme package created in: $THEME_DIR/"
    fi
  fi
  exit 0
fi
