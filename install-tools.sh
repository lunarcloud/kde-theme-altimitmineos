#!/bin/bash

# shellcheck disable=SC2034  # APP_NAME and ACTIVITY are used by script-dialog.sh functions

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# shellcheck source=./script-dialog/script-dialog.sh
pushd "$SCRIPT_DIR" || exit
source "./script-dialog/script-dialog.sh"

relaunch-if-not-visible

APP_NAME="ALTIMIT MINE OS Tool Installer"

if [ "$NO_SUDO" == true ]; then
  ACTIVITY="Privilege escalation unavailable"
  message-error "No supported privilege escalation tool is available. Install sudo or pkexec and try again."
  exit 1
fi

if command -v apt >/dev/null 2>&1; then
  distro_name="Ubuntu / Kubuntu"
  packages=(7zip imagemagick ffmpeg)
  install_command=(env DEBIAN_FRONTEND=noninteractive apt install -y)
elif command -v dnf >/dev/null 2>&1; then
  distro_name="Fedora"
  packages=(p7zip ImageMagick ffmpeg-free)
  install_command=(dnf install -y)
elif command -v pacman >/dev/null 2>&1; then
  distro_name="Arch"
  packages=(p7zip imagemagick ffmpeg)
  install_command=(pacman -S --needed --noconfirm)
elif command -v zypper >/dev/null 2>&1; then
  distro_name="openSUSE"
  packages=(p7zip ImageMagick ffmpeg)
  install_command=(zypper --non-interactive install)
else
  ACTIVITY="Unsupported system"
  message-error "This installer supports apt, dnf, pacman, and zypper based systems."
  exit 1
fi

ACTIVITY="Install packages"
if ! yesno "Install the required packages for ${distro_name}?\n\n${packages[*]}"; then
  message-info "Installation cancelled."
  exit 0
fi

ACTIVITY="Installing packages"
if ! superuser "${install_command[@]}" "${packages[@]}"; then
  message-error "Package installation failed."
  exit 1
fi

message-info "Installed packages for ${distro_name}: ${packages[*]}"
