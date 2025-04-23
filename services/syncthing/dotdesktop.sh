#!/bin/sh	
# install desktop files and icons

HOME_DATA="${XDG_DATA_HOME:-${HOME}/.local/share}"
ICON_URL="https://raw.githubusercontent.com/syncthing/syncthing/main/assets"
ICON_NAME="logo"

# Set downloader
if command -v curl > /dev/null 2>&1; then
    downloader="curl --connect-timeout 3 --retry 1 -sLo"
elif command -v wget > /dev/null 2>&1; then
    downloader="wget --timeout=3 --tries=1 -qO"
else
    echo "Please install wget or curl"
    exit 1
fi

# Ensure the destination directories exist
mkdir -p "${HOME_DATA}/applications"
mkdir -p "${HOME_DATA}/icons/hicolor"

# Download icons
for size in 32 64 128 256 512; do
    mkdir -p "${HOME_DATA}/icons/hicolor/${size}x${size}/apps"
    ${downloader} - "${ICON_URL}/${ICON_NAME}-${size}.png" > \
        "${HOME_DATA}/icons/hicolor/${size}x${size}/apps/syncthing.png"
done

mkdir -p "${HOME_DATA}/icons/hicolor/scalable/apps"
${downloader} - "${ICON_URL}/${ICON_NAME}-only.svg" > \
    "${HOME_DATA}/icons/hicolor/scalable/apps/syncthing.svg"

# Create Desktop Entry
HOME_DATA="${XDG_DATA_HOME:-${HOME}/.local/share}"
cat > "${HOME_DATA}/applications/syncthing-ui.desktop" <<EOF
[Desktop Entry]
Name=Syncthing Web UI
GenericName=File synchronization UI
Comment=Opens Syncthing's Web UI in the default browser \
(Syncthing must already be started).
Exec=sh -c "systemctl is-active --user --quiet syncthing.service && \
xdg-open \\\"https://127.0.0.1:8384\\\" || \
if [ \\\"\\\\\$(\
notify-send --app-name=syncthing.service \
--icon=syncthing \
--action=\\\"start=Start\\\" \
\\\"Synthing Not Running\\\" \
\\\"syncthing.service is not running state.\\\"\
)\\\" = \\\"start\\\" ]; then \
systemctl start --user syncthing.service; \
fi"
Icon=syncthing
Terminal=false
Type=Application
Keywords=synchronization;interface;
Categories=Network;FileTransfer;P2P
EOF

update-desktop-database "${HOME_DATA}/applications"