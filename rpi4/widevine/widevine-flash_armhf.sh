#!/bin/sh -eu

# Where to copy the widevine files to?
# for Kodi: cp ./libiwidevine 

# Make sure we have wget or curl
available () {
  command -v "$1" >/dev/null 2>&1
}
if available wget; then
  DL="wget -O-"
  DL_SL="wget -qO-"
elif available curl; then
  DL="curl -L"
  DL_SL="curl -s"
else
  echo "Install Wget or cURL" >&2
  exit 1
fi

# MNTPNT="/tmp/ChromeOS.F9weF6" # when already downloaded and mounted

if [[ ! -v MNTPNT ]]; then

  # Find a URL to a suitable armhf ChromeOS recovery image
  # CHROMEOS_URL="$($DL_SL https://dl.google.com/dl/edgedl/chromeos/recovery/recovery.conf | grep -A11 CB5-312T | sed -n 's/^url=//p')"
  CHROMEOS_IMG="$(basename "$CHROMEOS_URL" .zip)"
  if [ -e "$CHROMEOS_IMG" ]; then
    CHROMEOS_IMG_PATH="./"
    DEL_IMG=N
  else
    CHROMEOS_IMG_PATH="$(mktemp -td ChromeOS-IMG.XXXXXX)"
    DEL_IMG=Y
    # Fetch the recovery image (2Gb+ on disk after download)
    $DL "$CHROMEOS_URL" | zcat > "$CHROMEOS_IMG_PATH/$CHROMEOS_IMG"
  fi

  # Note the next free loop device in a variable
  LOOPD="$(losetup -f)"

  # If root, we can mount silently (no popup windows after mount)
  if [ "$USER" = "root" ]; then
    MNTPNT="$(mktemp -d -t ChromeOS.XXXXXX)"
    losetup -Pf "$CHROMEOS_IMG_PATH/$CHROMEOS_IMG"
    mount -o ro "${LOOPD}p3" "$MNTPNT"
  else
    # Associate all the partitions on the disk image with loop devices:
    udisksctl loop-setup -rf "$CHROMEOS_IMG_PATH/$CHROMEOS_IMG"
    sleep 1
    # Mount the third partition of the disk image (if the previous did not do it automatically)
    if ! lsblk -lo MOUNTPOINT "${LOOPD}p3" | tail -n1 | grep -q \.; then
      udisksctl mount -b "${LOOPD}p3"
    fi
    # Note the mount point in a variable
    MNTPNT="$(lsblk -lo MOUNTPOINT "${LOOPD}p3" | tail -n1)"
  fi

fi


# Copy over files and make manifest
CHRFILES="$(mktemp -d -t ChromeOS_Files.XXXXXX)"
# install -Dm644 "$MNTPNT"/opt/google/chrome/pepper/libpepflashplayer.so "$CHRFILES"/libpepflashplayer.so
install -Dm644 "$MNTPNT"/opt/google/chrome/WidevineCdm/_platform_specific/cros_arm/libwidevinecdm.so "$CHRFILES"/libwidevinecdm.so
WVVER="$(grep -Eaom1 '([0-9]+\.){3}[0-9]+' "$CHRFILES"/libwidevinecdm.so)"
WVMGR="$(echo $WVVER | cut -d. -f1)"
WVMIN="$(echo $WVVER | cut -d. -f2)"
echo "{\"version\":\"$WVVER\",\"x-cdm-codecs\":\"vp8,vp9.0,avc1,av01\",\"x-cdm-host-versions\":\"$WVMIN\",\"x-cdm-interface-versions\":\"$WVMIN\",\"x-cdm-module-versions\":\"$WVMGR\"}" > "$CHRFILES"/manifest.json

# Extract the libs out and copy them to a compressed tar archive
ARCHIVE_NAME="widevine-$(date '+%Y%m%d')_armhf.tgz"
echo "Extracting and compressing files"
# chmod 755 "$CHRFILES"/libpepflashplayer.so
chmod 755 "$CHRFILES"/libwidevinecdm.so
tar -C"$CHRFILES" -caf "$ARCHIVE_NAME" manifest.json libwidevinecdm.so --format ustar --owner 0 --group 0
rm -r "$CHRFILES"
echo "Created: $ARCHIVE_NAME"

# Cleanup
if [ "$USER" = "root" ]; then
  umount "$MNTPNT"
  losetup -d "$LOOPD"
  rmdir "$MNTPNT"
else
  ALLMNTS="$(lsblk -lo NAME,MOUNTPOINT "$LOOPD" | sed -n '/\//s/^\(loop[0-9]\+p[0-9]\+\).*/\1/p')"
  echo "$ALLMNTS" | xargs -I{} -n1 udisksctl unmount -b /dev/{}
  if [ "$LOOPD" != "$(losetup -f)" ]; then
    udisksctl loop-delete -b "$LOOPD"
  fi
fi
if [ "$DEL_IMG" = "N" ] || [ "${1:-EMPTY}" = "-k" ]; then
  :
else
  rm "$CHROMEOS_IMG_PATH/$CHROMEOS_IMG"
  rmdir -v "$CHROMEOS_IMG_PATH"
fi

# # Installing DRM support
# echo "Installing DRM support for Chromium"
# # check https://www.whatismybrowser.com/guides/the-latest-user-agent/chrome for the last version of the browsers
# USER_AGENT='--user-agent="Mozilla/5.0 (X11; CrOS armv7l 13099.85.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.110 Safari/537.36"'

# tar xf $ARCHIVE_NAME
# mkdir -p ${HOME}/.config/chromium-browser/WidevineCdm
# sudo mkdir -p /opt/WidevineCdm/_platform_specific/linux_arm
# echo '{"Path":"/opt/WidevineCdm"}' > ${HOME}/.config/chromium-browser/WidevineCdm/latest-component-updated-widevine-cdm
# sudo mv manifest.json /opt/WidevineCdm
# sudo mv libwidevinecdm.so /opt/WidevineCdm/_platform_specific/linux_arm 
# sudo mv libpepflashplayer.so /usr/lib/chromium-browser/

# # Changing user-agent to Chromium
# cp /usr/share/applications/chromium-browser.desktop .
# sed 's/Chromium/Chromium (DRM)/g' chromium-browser.desktop > chromium-drm-browser.desktop
# sed -i 's@Exec=chromium-browser %U@'"Exec=chromium-browser %U $USER_AGENT"'@' chromium-drm-browser.desktop
# sed -i 's@Exec=chromium-browser@'"Exec=chromium-browser $USER_AGENT"'@' chromium-drm-browser.desktop
# sed -i 's@Exec=chromium-browser --temp-profile@'"Exec=chromium-browser --temp-profile $USER_AGENT"'@' chromium-drm-browser.desktop 
# sed -i 's@Exec=chromium-browser --incognito@'"Exec=chromium-browser --incognito $USER_AGENT"'@' chromium-drm-browser.desktop
# sudo mv chromium-drm-browser.desktop /usr/share/applications/

# Clean up installation
#rm chromium-browser.desktop
#rm $ARCHIVE_NAME