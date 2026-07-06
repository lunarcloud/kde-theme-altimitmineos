ALTIMIT MINE OS Conversion to KDE theming
------------------------------------------------------

Now Linux users can enjoy this silly promotional disc theme.

## Download and Convert

This repository expects the ALTIMIT MINE OS ISO from https://archive.org/details/altimitmineos 
Then, run the scripts:
```bash
  ./install-tools.sh
  ./extract-altimitmineos.sh
  ./theme_convert.sh
```

## Outputs
./altimit_mine_os/ containing:
- colors/altimit_mine_os.colors (Breeze Light base + extracted theme colors)
- icons/ (48x48/apps with custom icons, inherits Yaru/Adwaita/Breeze)
- plasmarc/plasmarc (KDE Plasma configuration)
- sounds/altimit_mine_os/ (sound theme with KDE event mappings)
- wallpapers/ (theme wallpaper + preview images)
- wallpaper-package/altimit_mine_os/ (KDE wallpaper package for Wallpaper settings)
- contents/splash/ (boot splash screen with fade animation)
- metadata.json, metadata.desktop

## Install options
- Interactive (default): `./theme_convert.sh` — prompts to install
- Auto-install: `./theme_convert.sh --install` — create and install
- Skip install: `./theme_convert.sh --no-install` — create only
- Text UI: `INTERFACE=text ./theme_convert.sh --install` — avoid GUI hangs

Installed to:
- `~/.local/share/plasma/look-and-feel/altimit_mine_os/`
- `~/.local/share/wallpapers/altimit_mine_os/`

Then open System Settings > Appearance > Look and Feel to activate, or Wallpaper to pick **ALTIMIT MINE OS** directly.

## Notes
- Color scheme uses Breeze Light defaults, overridden by extracted theme colors where available
- Icon theme overrides system theme (Yaru/Adwaita/Breeze) only for mapped icons
- Sound events mapped to KDE standard names (service-login, dialog-positive, message-new-instant, etc.)
- Splash screen shows wallpaper with fading cube animation
- Update metadata.json/metadata.desktop to change author or version
- If you want to avoid GUI dialog dependencies, run the scripts in text mode: 
  ```bash
    INTERFACE=text ./extract-altimitmineos.sh
    INTERFACE=text ./theme_convert.sh --install
  ```

