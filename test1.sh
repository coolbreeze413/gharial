#!/usr/bin/env bash

WHICHTAG="v2.8.0"
au_device_package_pattern="testarray/PACKAGEPREFIX_*_en.tar.gz"
DEVICE_PACKAGES_ARRAY=($(ls ${au_device_package_pattern}))
NUM_FILES=${#DEVICE_PACKAGES_ARRAY[*]}
echo ">>> found : ${NUM_FILES} ${au_device_package_pattern} files"

echo
echo "array:"
echo ${DEVICE_PACKAGES_ARRAY[*]}
echo
echo

echo
echo
i=0
while [ $i -lt ${NUM_FILES} ] ; do
echo $i
  DEVICE_PACKAGE_CURRENT=${DEVICE_PACKAGES_ARRAY[$i]}
  echo ${DEVICE_PACKAGE_CURRENT}
  DEVICE_PACKAGE_CONTINUOUS=$(echo ${DEVICE_PACKAGE_CURRENT} | sed -e "s/${WHICHTAG}/continuous/")
  echo ${DEVICE_PACKAGE_CONTINUOUS}
  let i++
done

echo
echo
i=0
for DEVICE_PACKAGE_CURRENT in "${DEVICE_PACKAGES_ARRAY[@]}"; do
  echo $i
  echo "${DEVICE_PACKAGE_CURRENT}"
  DEVICE_PACKAGE_CONTINUOUS=$(echo "${DEVICE_PACKAGE_CURRENT}" | sed -e "s/${WHICHTAG}/continuous/")
  echo "${DEVICE_PACKAGE_CONTINUOUS}"
  let i++
done