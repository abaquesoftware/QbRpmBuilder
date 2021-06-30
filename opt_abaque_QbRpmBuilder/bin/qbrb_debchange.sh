#!/usr/bin/env bash

# ======================================================================
# Copyright 2020 Arnaud BAQUE (abaque@abaquesoftware.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ======================================================================

# --------------------------------------------
function show_help() {
# --------------------------------------------
  echo "Syntax: $0 (parameters)"
  echo "    parameters: --create"
  echo "                --package package-name"
  echo "                [-v package-version]"
  echo "            or"
  echo "                [-h|--help] : display this help"
}

# ============================================
# MAIN
# ============================================

qbrb_rootDir="/opt/abaque/QbRpmBuilder/bin"
[ -e "opt_abaque_QbRpmBuilder" ] && qbrb_rootDir="opt_abaque_QbRpmBuilder/bin"
source "${qbrb_rootDir}/qbrb_tools.inc.sh"

# -- read input parameters
qbrb_mode=""
qbrb_packageName=""
qbrb_packageVersion=""
qbrb_packageComment=""

while [ $# -gt 0 ]
do
PARAM="$1"
case ${PARAM} in
  --create)         qbrb_mode="create" ;;
  --package)        qbrb_packageName="$2"; shift ;;
  -v|--new-version) qbrb_packageVersion="$2"; shift ;;
  -h|--help) show_help ; exit 0 ;;
  *)
    if [ "${PARAM:0:1}" != "-" ] ; then
      qbrb_packageComment="${PARAM}"
    else
      echo "ERROR: $0 - Unknown option : ${PARAM}"
      echo ""
      show_help
      exit 1
    fi
    ;;
esac
shift
done

# set qbrb_maintainer
qbrb_packageMaintainer=""
if [ -n "${qbrb_packageVersion}" ] ; then
  qbrb_packageMaintainer="${DEBEMAIL}"
fi

# -- debug
# echo "mode: $qbrb_mode"
# echo "package: $qbrb_packageName"
# echo "version: $qbrb_packageVersion"
# echo "maintainer: $qbrb_packageMaintainer"
# echo "comment: $qbrb_packageComment"

[ "${qbrb_mode}" != "create" ] && echo "Error: $0 - Unknown mode. Please add --create" && exit 1

# Note: qbrbtools_... are valued by 'source qbrb_tools.inc.sh'
mkdir -p "${qbrbtools_distribDir}"
changeLogFile="${qbrbtools_distribDir}/changelog"

cat <<EOF > "${changeLogFile}"
${qbrb_packageName} (${qbrb_packageVersion}) UNRELEASED; urgency=medium

  * ${qbrb_packageComment}

 -- ${qbrb_packageMaintainer}  $( date -R )
EOF
