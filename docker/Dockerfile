ARG DISTRO="debian"
ARG RELEASE="bullseye"

FROM ${DISTRO}:${RELEASE}

ARG DISTRO
ARG RELEASE
ARG LLVM_VERSION="15"
ARG REPO_POSTFIX="-${LLVM_VERSION}"
ARG NODE_VERSION="16"

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && export DEBIAN_FRONTEND=noninteractive

## upgrade packages and install needed base packages to add a repo
RUN apt-get update --fix-missing && apt-get -y upgrade
RUN apt-get -y install ca-certificates wget lsb-release software-properties-common gnupg2

## add node_18 repo and get a newer nodejs version than 12 (leeds to build errors due to missing imports since chromium 105.xx)
RUN wget -O - https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
RUN add-apt-repository "deb https://deb.nodesource.com/node_${NODE_VERSION}.x ${RELEASE} main"
## add llvm tool chain
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
RUN add-apt-repository "deb http://apt.llvm.org/${RELEASE} llvm-toolchain-${RELEASE}${REPO_POSTFIX} main"

RUN apt-get update

## install node, all needed distro packages, and llvm toolchain
RUN apt-get -y install nodejs\
 git debhelper python-is-python3 python3 pkg-config ninja-build python3-jinja2 gsettings-desktop-schemas-dev flex yasm xvfb wdiff gperf bison valgrind xz-utils x11-apps xfonts-base libglew-dev libgl1-mesa-dev libglu1-mesa-dev libegl1-mesa-dev libgles2-mesa-dev mesa-common-dev libxt-dev libre2-dev libgbm-dev libpng-dev libxss-dev libelf-dev libvpx-dev libpci-dev libcap-dev libdrm-dev libicu-dev libffi-dev libkrb5-dev libexif-dev libflac-dev libudev-dev libopus-dev libwebp-dev libxtst-dev libjpeg-dev libxml2-dev libgtk-3-dev libxslt1-dev liblcms2-dev libpulse-dev libpam0g-dev libsnappy-dev libavutil-dev libavcodec-dev libavformat-dev libglib2.0-dev libasound2-dev libjsoncpp-dev libspeechd-dev libminizip-dev libhunspell-dev libusb-1.0-0-dev libopenjp2-7-dev libmodpbase64-dev libnss3-dev libnspr4-dev libcups2-dev libevent-dev libjs-jquery libjs-jquery-flot libgcrypt20-dev libva-dev fonts-ipafont-gothic fonts-ipafont-mincho uuid-dev xcb-proto python3-xcbgen python-setuptools libx11-xcb-dev libxcb-dri3-dev libxshmfence-dev imagemagick desktop-file-utils binutils libcurl4-openssl-dev qtbase5-dev\
 libllvm-${LLVM_VERSION}-ocaml-dev libllvm${LLVM_VERSION} llvm-${LLVM_VERSION} llvm-${LLVM_VERSION}-dev llvm-${LLVM_VERSION}-doc llvm-${LLVM_VERSION}-examples llvm-${LLVM_VERSION}-runtime clang-${LLVM_VERSION} clang-tools-${LLVM_VERSION} clang-${LLVM_VERSION}-doc libclang-common-${LLVM_VERSION}-dev libclang-${LLVM_VERSION}-dev libclang1-${LLVM_VERSION} clang-format-${LLVM_VERSION} clangd-${LLVM_VERSION} libfuzzer-${LLVM_VERSION}-dev lldb-${LLVM_VERSION} lld-${LLVM_VERSION} libc++-${LLVM_VERSION}-dev libc++abi-${LLVM_VERSION}-dev libomp-${LLVM_VERSION}-dev libunwind-${LLVM_VERSION}-dev

## update npm
RUN npm install -g npm@latest

## set all needed links
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${LLVM_VERSION} 800\
 && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-${LLVM_VERSION} 800\
 && update-alternatives --install /usr/bin/llvm-ar llvm-ar /usr/bin/llvm-ar-${LLVM_VERSION} 800\
 && update-alternatives --install /usr/bin/llvm-nm llvm-nm /usr/bin/llvm-nm-${LLVM_VERSION} 800
RUN llvm_package_version=$(apt list llvm-${LLVM_VERSION}-dev | grep -Po "\d+\.\d+\.\d+") &&\
  rm -f /usr/bin/lld && ln -s /usr/bin/lld-${LLVM_VERSION} /usr/bin/lld &&\
  rm -f /usr/bin/ld.lld && ln -s /usr/bin/ld.lld-${LLVM_VERSION} /usr/bin/ld.lld &&\
  rm -f /usr/bin/lld-link && ln -s /usr/bin/lld-link-${LLVM_VERSION} /usr/bin/lld-link &&\
  ln -s /usr/lib/llvm-${LLVM_VERSION}/lib/clang/${llvm_package_version}/share /usr/lib/clang/${llvm_package_version}/share 

## just for conveniance when opening a shell in container
RUN echo 'alias ll="ls -al"' >> /root/.bashrc

RUN mkdir /repo
WORKDIR /repo

