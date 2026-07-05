ALTIMIT MINE OS Conversion to KDE theming
------------------------------------------------------

## Download and Convert

This repository expects the ALTIMIT MINE OS assets extracted under ./contents.
Use the included extractor if you have the archive:

1. Place the ISO or asset archive in the folder
2. `./extract-altimitmineos.sh` (produces ./contents/)
3. `./theme_convert.sh`

**Output**: ./altimit_mine_os/ containing:
- colors/altimit_mine_os.colors
- plasmarc/plasmarc
- wallpapers/
- icons/
- sounds/altimit_mine_os/stereo/ (freedesktop sound theme)
- metadata.json, metadata.desktop, README.txt

## Install options
- Interactive (default): `./theme_convert.sh` — prompts to install after creating files.
- Auto-install: `./theme_convert.sh --install` — create and install to ~/.local/share/plasma/look-and-feel/
- Skip install: `./theme_convert.sh --no-install` — create and do not install.

Manual install (if desired):
  mkdir -p ~/.local/share/plasma/look-and-feel/
  cp -r "altimit_mine_os" ~/.local/share/plasma/look-and-feel/

Then open System Settings > Appearance > Look and Feel to activate.

## Notes
- Update metadata.json/metadata.desktop to change author or version.
- Assets must be provided by the user; this repo does not contain the original archive.
- Script provided as-is; run shellcheck if modifying.
