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
  echo "Syntax: $0 [--destdir dest-dir] [--filename file-name]"
}

# ============================================
# MAIN
# ============================================

qbrb_rootDir="/opt/abaque/QbRpmBuilder/bin"
[ -e "opt_abaque_QbRpmBuilder" ] && qbrb_rootDir="opt_abaque_QbRpmBuilder/bin"
source "${qbrb_rootDir}/qbrb_tools.inc.sh"

# -- read input parameters
qbrb_destDir=".."
qbrb_fileName=""

while [ $# -gt 0 ]
do
  PARAM="$1"
  PARAM_OK=0
  if [ "${PARAM:0:9}" == "--destdir" ] ; then
    if [ "${PARAM:9:1}" == "=" ] ; then
      qbrb_destDir="${PWD}/${PARAM:10}"
    else
      qbrb_destDir="${PWD}/$2"
      shift
    fi
    PARAM_OK=1
  fi
  if [ "${PARAM:0:10}" == "--filename" ] ; then
    if [ "${PARAM:10:1}" == "=" ] ; then
      qbrb_fileName="${PWD}/${PARAM:11}"
    else
      qbrb_fileName="${PWD}/$2"
      shift
    fi
    PARAM_OK=1
  fi
  if [ "${PARAM}" == "-h" -o "${PARAM}" == "--help" ] ; then
    show_help
    exit 0
  fi
  if [ ${PARAM_OK} -ne 1 ] ; then
    echo "ERROR: $0 - Unknown option : ${PARAM}"
    echo ""
    show_help
    exit 1
  fi
  shift
done

# Value variables qbrbtools_...
Qbrbtools_set_vars_from_files

qbrb_packageDir="${PWD}/${qbrbtools_distribDir}/${qbrbtools_packageName}"
qbrb_generatedRpmFile="${qbrbtools_packageName}"
[ -n "${qbrbtools_packageVersion}" ] && qbrb_generatedRpmFile+="-${qbrbtools_packageVersion}"
[ -n "${qbrbtools_packageRevision}" ] && qbrb_generatedRpmFile+="-${qbrbtools_packageRevision}"

rpmbuild -bb --target "${qbrbtools_architecture}" --define "_topdir ${qbrb_packageDir}"  "${qbrb_packageDir}/SPECS/package.specs"
mv "${qbrb_packageDir}/RPMS/${qbrbtools_architecture}/${qbrb_generatedRpmFile}."*.rpm "${qbrb_destDir}/"
