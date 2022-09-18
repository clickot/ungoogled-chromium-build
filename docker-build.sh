#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
GIT_REPO="ungoogled-chromium"

DISTRO_RELEASE=${1:-'debian-bullseye'}
#DISTRO_RELEASE=${1:-'ubuntu-jammy'}
LLVM_FULL_VERSION=${2:-'15.0.1'}

LLVM_VERSION=$(echo ${LLVM_FULL_VERSION}| cut -d. -f1)
DISTRO=$(echo ${DISTRO_RELEASE}| cut -d- -f1)
RELEASE=$(echo ${DISTRO_RELEASE}| cut -d- -f2)

IMAGE="chromium-builder:${RELEASE}-${LLVM_VERSION}"

cd $BASE_DIR 

if [ -z "$(docker images -q ${IMAGE})" ] ; then
    echo -e "image '${IMAGE}' not found, building it first.\n"
    (cd $BASE_DIR/docker && docker build -t ${IMAGE} --build-arg DISTRO=${DISTRO} --build-arg RELEASE=${RELEASE} --build-arg LLVM_VERSION=${LLVM_VERSION} --build-arg LLVM_FULL_VERSION=${LLVM_FULL_VERSION} .)
else
    echo -e "reusing existing image '${IMAGE}'...\n"
fi

git submodule update --init --recursive

BUILD_START=$(date)
echo "==============================================================="
echo "  docker build start at ${BUILD_START}"
echo "==============================================================="

cd ${BASE_DIR}

echo "docker run -it -v ${BASE_DIR}:/repo chromium-builder:${RELEASE}-${LLVM_VERSION} /bin/bash -c \"LLVM_VERSION=${LLVM_VERSION} /repo/build.sh\""
docker run -it -v ${BASE_DIR}:/repo chromium-builder:${RELEASE}-${LLVM_VERSION} /bin/bash -c "LLVM_VERSION=${LLVM_VERSION} /repo/build.sh"

BUILD_END=$(date)
echo "==============================================================="
echo "  docker build start at ${BUILD_START}"
echo "  docker build end   at ${BUILD_END}"
echo "==============================================================="

