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
  echo "Syntax: $0 (options)"
  echo "Options: "
  echo "     [--exclude file] or [--exclude=file] or [-Xfile]"               
  echo "     [-h|--help] : display help"
}

# ============================================
# MAIN
# ============================================

qbrb_rootDir="/opt/abaque/QbRpmBuilder/bin"
[ -e "opt_abaque_QbRpmBuilder" ] && qbrb_rootDir="opt_abaque_QbRpmBuilder/bin"
source "${qbrb_rootDir}/qbrb_tools.inc.sh"

# -- read input parameters
qbrb_excludedLinkList=""

while [ $# -gt 0 ]
do
  PARAM="$1"
  PARAM_OK=0
  if [ "${PARAM:0:9}" == "--exclude" ] ; then
    if [ "${PARAM:9:1}" == "=" ] ; then
      qbrb_excludedLinkList+="${PARAM:10} "
    else
      qbrb_excludedLinkList+="$2 "
      shift
    fi
    PARAM_OK=1
  fi
  if [ "${PARAM:0:2}" == "-X" ] ; then
    qbrb_excludedLinkList=+"${PARAM:2} "
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
qbrb_installDir="${qbrb_packageDir}/BUILD/${qbrbtools_packageName}-${qbrbtools_packageVersion}"
qbrb_confFile="$( Qbrbtools_get_config_file "${qbrbtools_packageName}" "links")"

if [ -n "${qbrb_confFile}" ] ; then
  while read line
  do
    linkLine="$( echo "${line}" | sed "s/[ |\\t]\+/ /g" | sed "s/^ //g" | sed "s/ $//g" )"
    if [ -n "${linkLine}" -a "${linkLine:0:1}" != "#" ] ; then
      srcLinkPath=$(  echo "${linkLine}" | awk '{print $1}' )
      destLinkPath=$( echo "${linkLine}" | awk '{print $2}' )
      if [ -z "${destLinkPath}" ] ; then
        echo "ERROR in 'dh_link' - Invalid copy '${line}'"
        exit 1
      fi
      destLinkDir=$( dirname "${destLinkPath}" )
      DST_DIR=$( dirname "${DST_LINK}" )
      mkdir -p "${qbrb_installDir}/${destLinkDir}"
      ln  -sf  "/${srcLinkPath}" "${qbrb_installDir}/${destLinkPath}"
    fi
  done < "${qbrb_confFile}"
fi

if [ -n "${qbrb_excludedLinkList}" ] ; then
  OLD_PWD="${PWD}"
  cd "${qbrb_installDir}"
  for excludedLink in ${qbrb_excludedLinkList}
  do
    find . -name "*${excludedLink}*" -exec rm -Rf '{}' \; > /dev/null 2>&1 || true 
  done
  cd "${OLD_PWD}"
fi
