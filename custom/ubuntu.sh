#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only

function install_mustrelyon(){
# 更新ubuntu源
${INS} update > /dev/null 2>&1

# 升级ubuntu
# ${INS} full-upgrade > /dev/null 2>&1

# 安装编译openwrt的依赖
${INS} install ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
bzip2 ccache cmake cpio curl device-tree-compiler flex gawk gcc-multilib g++-multilib gettext \
genisoimage git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev \
libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev \
libreadline-dev libssl-dev libtool llvm lrzsz msmtp ninja-build p7zip p7zip-full patch pkgconf \
python3 python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion \
swig texinfo uglifyjs unzip vim wget xmlto xxd zlib1g-dev

# N1打包需要的依赖
${INS} install rename pigz upx-ucl

${INS} clang-18 libclang-18-dev lld-18 liblld-18-dev
for i in "clang-18" "clang++-18" "clang-cpp-18" "ld.lld-18" "ld64.lld-18" "llc-18" "lld-18" "lld-link-18" "opt-18" "wasm-ld-18"; do
  sudo ln -svf "$i" "/usr/bin/${i%-18}"
done

# 安装po2lmo
${INS} install libncurses-dev libssl-dev libgmp-dev libexpat1-dev python3-pip
sudo rm -rf po2lmo
git clone --filter=blob:none --no-checkout "https://github.com/openwrt/luci.git" "po2lmo"
pushd "po2lmo"
git config core.sparseCheckout true
echo "modules/luci-base/src" >> ".git/info/sparse-checkout"
git checkout
cd "modules/luci-base/src"
sudo make po2lmo
sudo strip "po2lmo"
sudo rm -rf "/usr/bin/po2lmo"
sudo cp -fp "po2lmo" "/usr/bin/po2lmo"
popd
sudo rm -rf po2lmo

# 安装gcc-13
sudo add-apt-repository --yes ppa:ubuntu-toolchain-r/test
${INS} update > /dev/null 2>&1
${INS} install gcc-13 g++-13
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100
sudo update-alternatives --config gcc
sudo update-alternatives --config g++
gcc --version
g++ --version
clang --version
}

function update_apt_source(){
${INS} autoremove --purge
${INS} clean
}

function main(){
	if [[ -n "${BENDI_VERSION}" ]]; then
		export BENDI_VERSION="1"
		INS="sudo apt-get -y"
		echo "开始升级ubuntu插件和安装依赖....."
		install_mustrelyon
		update_apt_source
	else
		INS="sudo apt-get -y"
                echo "开始升级ubuntu插件和安装依赖....."
		install_mustrelyon
		update_apt_source
	fi
}

main
