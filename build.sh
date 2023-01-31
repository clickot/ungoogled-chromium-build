#!/bin/bash -eux

apt-get update && apt-get -y upgrade

# this script is an adaption of https://github.com/ungoogled-software/ungoogled-chromium-portablelinux/blob/master/build.sh

root_dir=$(dirname $(readlink -f $0))
download_cache="${root_dir}/target/download_cache"
src_dir="${root_dir}/target/src"
main_repo="${root_dir}/ungoogled-chromium"

rm -rf "${src_dir}" || true
rm -f "${root_dir}/target/domsubcache.tar.gz" || true
mkdir -p "${src_dir}/out/Default"
mkdir -p "${download_cache}"

"${main_repo}/utils/downloads.py" retrieve -i "${main_repo}/downloads.ini" -c "${download_cache}"
"${main_repo}/utils/downloads.py" unpack -i "${main_repo}/downloads.ini" -c "${download_cache}" "${src_dir}"
"${main_repo}/utils/prune_binaries.py" "${src_dir}" "${main_repo}/pruning.list"
"${main_repo}/utils/patches.py" apply "${src_dir}" "${main_repo}/patches"
"${main_repo}/utils/domain_substitution.py" apply -r "${main_repo}/domain_regex.list" -f "${main_repo}/domain_substitution.list" -c "${root_dir}/target/domsubcache.tar.gz" "${src_dir}"
cat "${main_repo}/flags.gn" "${root_dir}/flags.gn" > "${src_dir}/out/Default/args.gn"

export LLVM_VERSION=${LLVM_VERSION:=16}
export AR=${AR:=llvm-ar-${LLVM_VERSION}}
export NM=${NM:=llvm-nm-${LLVM_VERSION}}
export CC=${CC:=clang-${LLVM_VERSION}}
export CXX=${CXX:=clang++-${LLVM_VERSION}}
export LLVM_BIN=${LLVM_BIN:=/usr/lib/llvm-${LLVM_VERSION}/bin}

llvm_resource_dir=$("$CC" --print-resource-dir)
export CXXFLAGS+="-resource-dir=${llvm_resource_dir} -B${LLVM_BIN}"
export CPPFLAGS+="-resource-dir=${llvm_resource_dir} -B${LLVM_BIN}"
export CFLAGS+="-resource-dir=${llvm_resource_dir} -B${LLVM_BIN}"

cd "${src_dir}"

# ugly hack to bypass the check for a certain llvm package version (seems to be introduced in chromium 107.xx)
sed -i 's/ReadStampFile(STAMP_FILE).partition\(.*\)\[0\]/PACKAGE_VERSION/' ./tools/clang/scripts/update.py

./tools/gn/bootstrap/bootstrap.py -o out/Default/gn --skip-generate-buildfiles
./out/Default/gn gen out/Default --fail-on-unused-args

# instead if installing node as node_module, simply link to the node binary installed on OS 
mkdir -p third_party/node/linux/node-linux-x64/bin && ln -s /usr/bin/node third_party/node/linux/node-linux-x64/bin/

ninja -C out/Default chrome chrome_sandbox chromedriver
