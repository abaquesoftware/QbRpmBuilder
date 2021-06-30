#!/usr/bin/env bash

set -e

# Check root
[ "$( id -un )" != "root" ] && ( echo "ERROR: Must be root" ; exit 1 )

# ------ build -------------------------------------
cat > /tmp/hello-world.sh <<EOF
#!/usr/bin/env bash
echo "Hello world - version ##VERSION##"
EOF
chmod 755 /tmp/hello-world.sh
# ------ build -------------------------------------

packagename="qbrbtest"
version="1.0.0-1"
name="Abaque <abaque@abaquesoftware.com>"
comment="Updated to version ${version}"

DISTRIB="rpm"
[ -e /etc/debian_version ] && DISTRIB="debian"

# delete previous debian directory and recreate it
[ -e "${DISTRIB}" ] && rm -rf "${DISTRIB}"
mkdir "${DISTRIB}"
mkdir -p "dist-${DISTRIB}"


# --------------------------------
# Changelog file
# --------------------------------
env DEBEMAIL="${name}" debchange --create --package "${packagename}" -v "${version}" "Updated to version ${version}"

# --------------------------------
# Control file
# --------------------------------
DEPENDS=""
ARCHITECTURE="amd64"

cat <<EOF > "${DISTRIB}/control"
Source: ${packagename}
Section: base
Priority: optional
Maintainer: ${name}
Version: ${version}

Package: ${packagename}
Depends: ${DEPENDS}
Architecture: ${ARCHITECTURE}
Description: ${packagename}, version ${version}
EOF

# --------------------------------
# Compat
# --------------------------------
echo 9 > "${DISTRIB}/compat"

# --------------------------------
# Dirs
# --------------------------------
cat <<EOF > "${DISTRIB}/${packagename}.dirs"
opt/abaque/qbrbtest
EOF

# --------------------------------
# Files
# --------------------------------
cat <<EOF > "${DISTRIB}/${packagename}.install"
/tmp/hello-world.sh  opt/abaque/qbrbtest/
EOF

# --------------------------------
# Links
# --------------------------------
cat <<EOF > "${DISTRIB}/${packagename}.links"
opt/abaque/qbrbtest/hello-world.sh  usr/bin/qbrbtest
EOF

# --------------------------------
# Preinst
# --------------------------------
cat <<EOF > "${DISTRIB}/${packagename}.preinst"
#!/bin/sh
set -e
echo "*******************************"
echo "SCRIPT PRE-INST - version: ${version}"
echo "*******************************"
echo "PARAM-1 : <\$1>"
echo "PARAM-2 : <\$2>"
echo "PARAM-1 can be 'install' or 'upgrade' (or 'abort-upgrade' on Debian)"
echo "*******************************"
#DEBHELPER#
exit 0
EOF

# --------------------------------
# Postinst
# --------------------------------
cat <<EOF > "${DISTRIB}/${packagename}.postinst"
#!/bin/sh
set -e
echo "*******************************"
echo "SCRIPT POST-INST - version: ${version}"
echo "*******************************"
echo "PARAM-1 : <\$1>"
echo "PARAM-2 : <\$2>"
echo "PARAM-1 can be 'configure'"
echo "PARAM-2 is most-recently-configured-version"
echo "*******************************"
#DEBHELPER#
exit 0
EOF

# --------------------------------
# Prerm
# --------------------------------
cat <<EOF > "${DISTRIB}/${packagename}.prerm"
#!/bin/sh
set -e
echo "*******************************"
echo "SCRIPT PRE-RM - version: ${version}"
echo "*******************************"
echo "PARAM-1 : <\$1>"
echo "PARAM-2 : <\$2>"
echo "PARAM-1 can be 'remove' or 'upgrade' (or 'deconfigure' with DEB package, or 'upgrade-to-non-qbrpmbuilder-package' with RPM package)"
echo "*******************************"
#DEBHELPER#
exit 0
EOF

# --------------------------------
# Postrm
# --------------------------------
cat <<EOF > "${DISTRIB}/${packagename}.postrm"
#!/bin/sh
set -e
echo "*******************************"
echo "SCRIPT POST-RM - version: ${version}"
echo "*******************************"
echo "PARAM-1 : <\$1>"
echo "PARAM-2 : <\$2>"
echo "PARAM-1 can be 'remove' or 'upgrade' (or 'purge' or 'disappear' with DEB package, or 'upgrade-to-non-qbrpmbuilder-package' with RPM package)"
echo "*******************************"
#DEBHELPER#
exit 0
EOF

# -------------------------------------------
# Call debhelper commands to build package
# -------------------------------------------
dh_testroot
dh_prep
dh_installdirs
#dh_auto_install
dh_install
#dh_installdocs
#dh_installchangelogs
#dh_installexamples
#dh_installman
#dh_installcatalogs
#dh_installcron
#dh_installdebconf
#dh_installemacsen
#dh_installifupdown
#dh_installinfo
#dh_installinit
#dh_installmenu
#dh_installmime
#dh_installmodules
#dh_installlogcheck
#dh_installlogrotate
#dh_installpam
#dh_installppp
#dh_installudev
#dh_installwm
#dh_installxfonts
#dh_bugfiles
#dh_lintian
#dh_gconf
#dh_icons
#dh_perl
#dh_usrlocal
dh_link
#dh_compress
#dh_fixperms
#dh_strip
#dh_makeshlibs
#dh_shlibdeps
dh_installdeb
dh_gencontrol
#dh_md5sums
dh_builddeb --destdir=dist-$DISTRIB
