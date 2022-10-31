#!/bin/bash


BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
GIT_REPO="ungoogled-chromium"

DISTRO_RELEASE=${1:-'debian:bullseye'}
#DISTRO_RELEASE=${1:-'ubuntu:jammy'}
LLVM_VERSION=${2:-'15'}

DISTRO=$(echo ${DISTRO_RELEASE}| cut -d':' -f1)
RELEASE=$(echo ${DISTRO_RELEASE}| cut -d':' -f2)
[ $LLVM_VERSION == "16" ] || REPO_POSTFIX="-$LLVM_VERSION"

#LLVM_FULL_VERSION=$(curl -s https://api.github.com/repos/llvm/llvm-project/releases/latest | jq .tag_name | sed 's/llvmorg\-//' | sed 's/\"//g') 
echo -e "using DISTRO='$DISTRO' RELEASE='$RELEASE' LLVM_VERSION='$LLVM_VERSION'\n" 

IMAGE="chromium-builder-${RELEASE}:llvm-${LLVM_VERSION}"

cd $BASE_DIR 

if [ -z "$(docker images -q ${IMAGE})" ] ; then
    echo -e "image '${IMAGE}' not found, building it first.\ndocker build -t ${IMAGE} --build-arg DISTRO=${DISTRO} --build-arg RELEASE=${RELEASE} --build-arg LLVM_VERSION=${LLVM_VERSION} --build-arg REPO_POSTFIX=${REPO_POSTFIX} ."
    (cd $BASE_DIR/docker && docker build -t ${IMAGE} --build-arg DISTRO=${DISTRO} --build-arg RELEASE=${RELEASE} --build-arg LLVM_VERSION=${LLVM_VERSION} --build-arg REPO_POSTFIX=${REPO_POSTFIX} . )
else
    echo -e "reusing existing image '${IMAGE}'...\n"
fi

git submodule update --init --recursive

BUILD_START=$(date)
echo "==============================================================="
echo "  docker build start at ${BUILD_START}"
echo "==============================================================="

cd ${BASE_DIR}

echo "docker run -it -v ${BASE_DIR}:/repo ${IMAGE} /bin/bash -c \"LLVM_VERSION=${LLVM_VERSION} /repo/build.sh\""
docker run -it -v ${BASE_DIR}:/repo ${IMAGE} /bin/bash -c "LLVM_VERSION=${LLVM_VERSION} /repo/build.sh"

BUILD_END=$(date)
echo "==============================================================="
echo "  docker build start at ${BUILD_START}"
echo "  docker build end   at ${BUILD_END}"
echo "==============================================================="

