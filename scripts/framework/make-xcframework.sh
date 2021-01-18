#!/usr/bin/env bash
# Usage: make-xcframework <framework name without ext> <source dir> <output dir>
# e.g. make-xcframework Turf path/to/framework ./xcframework_dir

# Extract arm64
TMP_DIR=tmp_xcframework/$1/arm64
mkdir -p ${TMP_DIR}
cp -r $2/$1.framework ${TMP_DIR}
lipo ${TMP_DIR}/$1.framework/$1 -extract arm64 -output ${TMP_DIR}/$1.framework/$1

# Extract x86
TMP_DIR=tmp_xcframework/$1/x86_64
mkdir -p ${TMP_DIR}
cp -r $2/$1.framework ${TMP_DIR}
lipo ${TMP_DIR}/$1.framework/$1 -extract x86_64 -output ${TMP_DIR}/$1.framework/$1

# Make xcframework
xcodebuild -create-xcframework \
    -framework tmp_xcframework/$1/arm64/$1.framework \
    -framework tmp_xcframework/$1/x86_64/$1.framework \
    -output $3/$1.xcframework

rm -rf tmp_xcframework
