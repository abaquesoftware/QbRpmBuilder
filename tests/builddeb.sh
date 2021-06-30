#!/usr/bin/env bash

set -e

# "build"
cat > /tmp/hello-world.sh <<EOF
#!/usr/bin/env bash
echo Hello world - version ##VERSION##
EOF
chmod 755 /tmp/hello-world.sh

packagename="qbrbtest"
version="##VERSION##"
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
# dch/debchange is not supported for RPM packages
env DEBEMAIL="${name}" debchange --create --package "${packagename}" -v "${version}" "Updated to version ${version}"

#echo "${packagename}" > "${DISTRIB}/chlog_packagename"
#echo "${version}"     > "${DISTRIB}/chlog_version"
#echo "${name}"        > "${DISTRIB}/chlog_email"
#echo "${comment}"     > "${DISTRIB}/chlog_comment"

# --------------------------------
# Control file
# --------------------------------
DEPENDS=""

cat <<EOF > "${DISTRIB}/control"
Source: ${packagename}
Section: base
Priority: optional
Maintainer: ${name}
Version: ${version}

Package: ${packagename}
Depends: $DEPENDS
Architecture: amd64
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
echo "PARAM-1 can be 'install', 'upgrade' or 'abort-upgrade'"
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
echo "PARAM-1 can be 'remove', 'upgrade' or 'deconfigure'"
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
echo "PARAM-1 can be 'remove', 'purge', 'upgrade' or 'disappear'"
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
dh_install
dh_link
dh_installdeb
dh_gencontrol
dh_builddeb --destdir=dist-$DISTRIB

