#!/bin/bash

WORKSPACE_DIR="/data/users/torsten/workspace"
SOFTWARE_DIR="/data/users/torsten/software"

PATH_TO_BUILD_GIT_REPO="${WORKSPACE_DIR}/clickot/ungoogled-chromium-build"
PATH_TO_PUBLISH_GIT_REPO="${WORKSPACE_DIR}/clickot/ungoogled-chromium-binaries"
BINARIES_DIR="${SOFTWARE_DIR}/ungoogled-chromium"

REPO_TAG="$(cd ${PATH_TO_BUILD_GIT_REPO} && git describe --tags --abbrev=0)"
TAG="${REPO_TAG%.1}"

cd ${PATH_TO_PUBLISH_GIT_REPO}
# forced reset to upstream repo
git checkout master && git pull --rebase
git fetch upstream
git reset --hard upstream/master
git push origin master --force

./utilities/submit_github_binary.py --skip-checks --tag ${TAG} --username clickot --output config/platforms/linux_portable/64bit/ ${BINARIES_DIR}/ungoogled-chromium_${TAG}*.tar.xz 
./utilities/submit_github_binary.py --skip-checks --tag ${TAG} --username clickot --output config/platforms/appimage/64bit/ ${BINARIES_DIR}/ungoogled-chromium_${TAG}*.AppImage 

