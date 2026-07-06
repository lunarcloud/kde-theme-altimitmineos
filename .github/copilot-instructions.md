Copilot instructions for KDE Plasma theme ALTIMIT MINE OS repo

Purpose
- Help maintainers and contributors use Copilot features productively for this repo.

What to suggest
- Script improvements: color handling, icon mapping, sound event names, wallpaper/splash processing.
- Small focused edits with shellcheck validation and verification steps.
- Changes that assume contents/ contains extracted PNG/OGG assets.

What not to do
- Do not fetch or upload Internet Archive assets; repo expects manual extraction to contents/.
- Do not commit secrets, credentials, or asset dumps.
- Do not perform git commits or pushes — users commit changes themselves.

Key script behaviors (document present state only)
- Color scheme: Breeze Light base + extracted theme color overrides.
- Icon theme: 48x48/apps directory, inherits Yaru/Adwaita/Breeze (first found).
- Icons: Mapped to KDE standard names (application-internet, evolution, vlc, etc.).
- Sound events: Mapped to KDE standard names (service-login, dialog-positive, message-new-instant, etc.).
- Splash screen: Wallpaper background + fading cube animation (lower third).
- Text UI: Use INTERFACE=text to avoid GUI dialogs.

Local testing
- Extract assets: `./extract-altimitmineos.sh`
- Convert + install: `INTERFACE=text ./theme_convert.sh --install`
- Verify: Check ~/.local/share/plasma/look-and-feel/altimit_mine_os/, ~/.local/share/color-schemes/, ~/.local/share/icons/altimit_mine_os/

Language style
- Present-tense descriptions only (what things ARE, not what changed).
- Code comments explain function/purpose, not actions.
- Example: "Converts wallpaper to 128x128 animation frame" not "Added animation frame conversion".
