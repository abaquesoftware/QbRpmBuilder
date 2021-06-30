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
  echo "Syntax: $0 [-h|--help]"
}

# ============================================
# MAIN
# ============================================

qbrb_rootDir="/opt/abaque/QbRpmBuilder/bin"
[ -e "opt_abaque_QbRpmBuilder" ] && qbrb_rootDir="opt_abaque_QbRpmBuilder/bin"
source "${qbrb_rootDir}/qbrb_tools.inc.sh"

# -- read input parameters
if [ -n "$1" ] ; then
  if [ "$1" == "-h" -o "${PARAM}" == "--help" ] ; then
    show_help
    exit 0
  else
    echo "ERROR: $0 - Unknown option : ${1}"
    echo ""
    show_help
    exit 1
  fi
fi

# Value variables qbrbtools_...
Qbrbtools_set_vars_from_files

qbrb_packageDir="${PWD}/${qbrbtools_distribDir}/${qbrbtools_packageName}"
qbrb_installDir="${qbrb_packageDir}/BUILD/${qbrbtools_packageName}-${qbrbtools_packageVersion}"

mkdir -p "${qbrb_packageDir}/SRPMS"
mkdir -p "${qbrb_packageDir}/SPECS"
mkdir -p "${qbrb_packageDir}/SOURCES"
mkdir -p "${qbrb_packageDir}/RPMS"
mkdir -p "${qbrb_packageDir}/BUILDROOT"
mkdir -p "${qbrb_packageDir}/BUILD"
mkdir -p "${qbrb_installDir}"

