#!/usr/bin/env bash

# ------------------------------------
# Requirements:
# 
#   . rpm-build
# ------------------------------------

set -e

# Check root
[ "$( id -un )" != "root" ] && ( echo "ERROR: Must be root" ; exit 1 )
# Check bin directory
[ ! -d "./opt_abaque_QbRpmBuilder/bin" ] && ( echo "ERROR: Cannot find directory './opt_abaque_QbRpmBuilder/bin'" ; exit 1 )

packagename="qbrpmbuilder"
version="1.0.1"
name="Abaque <abaque@abaquesoftware.com>"
comment="Updated to version ${version}"

DISTRIB="_UNKNOWN_"
[ -e /etc/debian_version ] && DISTRIB="debian"
[ -e /etc/redhat-release ] && DISTRIB="rpm"

# Check missing pacakge
[ "$DISTRIB" = "rpm" ] && yum install -y rpmdevtools

# delete previous debian directory and recreate it
[ -e "${DISTRIB}" ] && rm -rf "${DISTRIB}"
mkdir "${DISTRIB}"
mkdir -p "./dist-${DISTRIB}"

# --------------------------------
# Changelog file
# --------------------------------
# dch/debchange is not supported for RPM packages
env DEBEMAIL="${name}" opt_abaque_QbRpmBuilder/bin/qbrb_debchange.sh --create --package "${packagename}" -v "${version}" "Updated to version ${version}"

#echo "${packagename}" > "${DISTRIB}/chlog_packagename"
#echo "${version}"     > "${DISTRIB}/chlog_version"
#echo "${name}"        > "${DISTRIB}/chlog_email"
#echo "${comment}"     > "${DISTRIB}/chlog_comment"

# --------------------------------
# Control file
# --------------------------------
DEPENDS="coreutils, bash, rpm-build"

cat <<EOF > "${DISTRIB}/control"
Source: ${packagename}
Section: base
Priority: optional
Maintainer: ${name}
Version: ${version}

Package: ${packagename}
Depends: $DEPENDS
Architecture: all
Description: ${packagename}, version ${version}
EOF

# Tobe tested:
# Recommends: ....
# Suggests: ...
# Enhances: ...
# Pre-Depends: ...
# Breaks: ...
# Conflicts: ...
# Provides: ...
# Replaces: ...

# --------------------------------
# Compat
# --------------------------------
echo 9 > "${DISTRIB}/${packagename}.compat"

# --------------------------------
# Dirs
# --------------------------------
cat <<EOF > "${DISTRIB}/${packagename}.dirs"
opt/abaque/QbRpmBuilder
opt/abaque/QbRpmBuilder/samples
opt/abaque/QbRpmBuilder/default-conf
EOF

# --------------------------------
# Files
# --------------------------------
cat <<EOF > "${DISTRIB}/${packagename}.install"
opt_abaque_QbRpmBuilder/*  opt/abaque/QbRpmBuilder/
EOF

# --------------------------------
# Links
# --------------------------------
cat <<EOF > "${DISTRIB}/${packagename}.links"
opt/abaque/QbRpmBuilder/bin/qbrb_debchange.sh       usr/bin/debchange
opt/abaque/QbRpmBuilder/bin/qbrb_debchange.sh       usr/bin/dch
opt/abaque/QbRpmBuilder/bin/qbrb_dh_builddeb.sh     usr/bin/dh_builddeb
opt/abaque/QbRpmBuilder/bin/qbrb_dh_gencontrol.sh   usr/bin/dh_gencontrol
opt/abaque/QbRpmBuilder/bin/qbrb_dh_installdeb.sh   usr/bin/dh_installdeb
opt/abaque/QbRpmBuilder/bin/qbrb_dh_installdirs.sh  usr/bin/dh_installdirs
opt/abaque/QbRpmBuilder/bin/qbrb_dh_install.sh      usr/bin/dh_install
opt/abaque/QbRpmBuilder/bin/qbrb_dh_link.sh         usr/bin/dh_link
opt/abaque/QbRpmBuilder/bin/qbrb_dh_prep.sh         usr/bin/dh_prep
opt/abaque/QbRpmBuilder/bin/qbrb_dh_testroot.sh     usr/bin/dh_testroot
EOF

# --------------------------------
# Postinst
# --------------------------------
cat <<EOF > "${DISTRIB}/${packagename}.postinst"
#!/bin/sh
set -e
if [ "\$1" = "configure" ] ; then
  mkdir -p "/etc/QbRpmBuilder"
  mkdir -p "/var/lib/qbrb-cache"
  if [ ! -e "/etc/QbRpmBuilder/QbRpmBuilder.conf" -o -z "\$( cat /etc/QbRpmBuilder/QbRpmBuilder.conf )" ] ; then
     mkdir -p "/etc/QbRpmBuilder"
     cp "/opt/abaque/QbRpmBuilder/default-conf/QbRpmBuilder.conf" "/etc/QbRpmBuilder/QbRpmBuilder.conf"
  fi
fi
#DEBHELPER#
exit 0
EOF

export RPMBUILD_LICENSE="Proprietary"

# -------------------------------------------
# Call debhelper commands to build package
# -------------------------------------------
opt_abaque_QbRpmBuilder/bin/qbrb_dh_testroot.sh
opt_abaque_QbRpmBuilder/bin/qbrb_dh_prep.sh
opt_abaque_QbRpmBuilder/bin/qbrb_dh_installdirs.sh
opt_abaque_QbRpmBuilder/bin/qbrb_dh_install.sh --exclude=.svn
opt_abaque_QbRpmBuilder/bin/qbrb_dh_link.sh
opt_abaque_QbRpmBuilder/bin/qbrb_dh_installdeb.sh
opt_abaque_QbRpmBuilder/bin/qbrb_dh_gencontrol.sh
opt_abaque_QbRpmBuilder/bin/qbrb_dh_builddeb.sh --destdir=dist-${DISTRIB}
