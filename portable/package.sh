#!/bin/bash

CURRENT_DIR=$(dirname $(readlink -f $0))

PACKAGE_START=$(date)
echo "==============================================================="
echo "  package tar.xz start at $PACKAGE_START"
echo "==============================================================="

ROOT_DIR=${CURRENT_DIR}/ungoogled-chromium-portablelinux

chromium_version=$(cat ${ROOT_DIR}/ungoogled-chromium/chromium_version.txt)
ungoogled_revision=$(cat ${ROOT_DIR}/ungoogled-chromium/revision.txt)
package_revision=$(cat ${ROOT_DIR}/revision.txt)

FILE_PREFIX=ungoogled-chromium_${chromium_version}-${ungoogled_revision}.${package_revision}
ARCHIVE_OUTPUT="${CURRENT_DIR}/${FILE_PREFIX}_linux.tar.xz"

set -eux

# the following mechanism does not work anymore since there is no .../tools/build/linux/FILES.cfg anymore
# so we pack tar.xz "by hand"

#"${ROOT_DIR}/ungoogled-chromium/utils/filescfg.py" \
#	-c "${ROOT_DIR}/build/src/chrome/tools/build/linux/FILES.cfg" \
#	--build-outputs "${ROOT_DIR}/build/src/out/Default" \
#	archive \
#	-o "${ARCHIVE_OUTPUT}" \
#	-i "${ROOT_DIR}/tar_includes/README"

FILES="chrome
chrome_100_percent.pak
chrome_200_percent.pak
chrome_crashpad_handler
chromedriver
chrome_sandbox
chrome-wrapper
icudtl.dat
libEGL.so
libGLESv2.so
libvk_swiftshader.so
libvulkan.so.1
locales/
product_logo_48.png
resources/
resources.pak
v8_context_snapshot.bin
vk_swiftshader_icd.json
xdg-mime
xdg-settings"

mkdir ${CURRENT_DIR}/${FILE_PREFIX}_linux
cp ${ROOT_DIR}/tar_includes/README ${CURRENT_DIR}/${FILE_PREFIX}_linux
for i in $FILES ; do 
    cp -r ${ROOT_DIR}/build/src/out/Default/$i ${CURRENT_DIR}/${FILE_PREFIX}_linux
done

(cd ${CURRENT_DIR} && tar cf ${FILE_PREFIX}_linux.tar ${FILE_PREFIX}_linux)

rm -rf ${CURRENT_DIR}/${FILE_PREFIX}_linux && xz "${CURRENT_DIR}/${FILE_PREFIX}_linux.tar"

set +eux

APPIMAGE_START=$(date)
echo "==============================================================="
echo "  package tar.xz   start at $PACKAGE_START"
echo "  package AppImage start at $APPIMAGE_START"
echo "==============================================================="

if [ ! -d "${CURRENT_DIR}/AppImages" ]; then
  mkdir -p ${CURRENT_DIR}/AppImages
  wget -c "https://github.com/AppImage/AppImages/raw/master/pkg2appimage" -P ${CURRENT_DIR}/AppImages
  chmod 755 ${CURRENT_DIR}/AppImages/pkg2appimage
fi
cp ungoogled-chromium.yml ungoogled-chromium.desktop ${CURRENT_DIR}/AppImages

cd ${CURRENT_DIR}/AppImages
./pkg2appimage ungoogled-chromium.yml

mv out/*.AppImage ${CURRENT_DIR}/${FILE_PREFIX}.AppImage

APPIMAGE_END=$(date)
echo "==============================================================="
echo "  package tar.xz   start at $PACKAGE_START"
echo "  package AppImage start at $APPIMAGE_START"
echo "  package AppImage end   at $APPIMAGE_END"
echo "==============================================================="
