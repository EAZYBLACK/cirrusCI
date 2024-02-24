#!/bin/bash

set -e
set -x

# sync rom
repo init
repo init -u https://github.com/crdroidandroid/android.git -b 11.0 --git-lfs --depth=1
git clone https://github.com/EAZYBLACK/judyln_manifest.git --depth=1 -b R .repo/local_manifests
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)
cd .repo/local_manifests
chmod +x setup.sh
chmod +x rom.sh
./setup.sh
./rom.sh
cd ../..
git remote add other https://github.com/juleast/android_build_soong.git
git fetch other
git cherry-pick 69b1f28

# build rom
source build/envsetup.sh
lunch lineage_judyln-eng
m bacon -j$(nproc --all)

# upload rom
up(){
	curl --upload-file $1 https://transfer.sh/$(basename $1); echo
	# 14 days, 10 GB limit
}

up out/target/product/judyln/*.zip
