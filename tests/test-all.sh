#!/usr/bin/env bash

echo "=========== Build all tests packages (version 0.0.1 to 0.0.4)"
echo ""
mkdir -p dist-rpm
ROOTDIR="${PWD}/tests/"

if [ "$( id -un )" != "root" ] ; then
  echo ""
  echo "ERROR: Must be root."
  echo ""
  exit 1
fi

echo ""
echo ""
echo "****************************************"
echo "* Clean-up"
echo "****************************************"
echo ""
sudo rpm -e qbrpmbuilder
sudo rpm -e qbrbtest

echo ""
echo ""
echo "****************************************"
echo "* Rebuild QbRpmBuilder"
echo "****************************************"
echo ""
./buildpackage.sh

echo ""
echo ""
echo "****************************************"
echo "* Install QbRpmBuilder"
echo "****************************************"
echo ""
RPM_PACKAGE="$( ls -t dist-rpm/qbrpmbuilder-* | head -n 1 )"
if [ -z "${RPM_PACKAGE}" ] ; then
  echo ""
  echo "ERROR: no RPM package 'qbrpmbuilder' found"
  echo ""
  exit 1
fi
rpm -Uvh "${RPM_PACKAGE}"

echo ""
echo ""
echo "****************************************"
echo "* Version 0.0.1"
echo "****************************************"
echo ""
SPEC_FILE="/tmp/v_0_0_1.specs"
BUILD_DIR="/tmp/v_0_0_1.build"
cp "${ROOTDIR}/rpm-specs"  "${SPEC_FILE}"
sed -i "s/##VERSION##/0.0.1/" "${SPEC_FILE}"
rm -Rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"
rpmbuild --define "_topdir ${BUILD_DIR}" -bb "--buildroot=${BUILD_DIR}" "${SPEC_FILE}"
find "${BUILD_DIR}/" -name "*.rpm" -exec mv '{}' dist-rpm/ \;
rm -Rf "${BUILD_DIR}"

echo ""
echo ""
echo "****************************************"
echo "* Version 0.0.2"
echo "****************************************"
echo ""
SPEC_FILE="/tmp/v_0_0_2.sh"
cp "${ROOTDIR}/builddeb.sh"  "${SPEC_FILE}"
sed -i "s/##VERSION##/0.0.2/" "${SPEC_FILE}"
chmod 755 "${SPEC_FILE}"
"${SPEC_FILE}"


echo ""
echo ""
echo "****************************************"
echo "* Version 0.0.3"
echo "****************************************"
echo ""
SPEC_FILE="/tmp/v_0_0_3.sh"
cp "${ROOTDIR}/builddeb.sh"  "${SPEC_FILE}"
sed -i "s/##VERSION##/0.0.3/" "${SPEC_FILE}"
chmod 755 "${SPEC_FILE}"
"${SPEC_FILE}"

echo ""
echo ""
echo "****************************************"
echo "* Version 0.0.4"
echo "****************************************"
echo ""
SPEC_FILE="/tmp/v_0_0_4.specs"
BUILD_DIR="/tmp/v_0_0_4.build"
cp "${ROOTDIR}/rpm-specs"  "${SPEC_FILE}"
sed -i "s/##VERSION##/0.0.4/" "${SPEC_FILE}"
rm -Rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"
rpmbuild --define "_topdir ${BUILD_DIR}" -bb "--buildroot=${BUILD_DIR}" "${SPEC_FILE}"
find "${BUILD_DIR}/" -name "*.rpm" -exec mv '{}' dist-rpm/ \;
rm -Rf "${BUILD_DIR}"


