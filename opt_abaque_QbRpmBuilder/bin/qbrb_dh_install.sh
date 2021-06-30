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
qbrb_excludedFileList=""

while [ $# -gt 0 ]
do
  PARAM="$1"
  PARAM_OK=0
  if [ "${PARAM:0:9}" == "--exclude" ] ; then
    if [ "${PARAM:9:1}" == "=" ] ; then
      qbrb_excludedFileList+="${PARAM:10} "
    else
      qbrb_excludedFileList+="$2 "
      shift
    fi
    PARAM_OK=1
  fi
  if [ "${PARAM:0:2}" == "-X" ] ; then
    qbrb_excludedFileList=+"${PARAM:2} "
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
qbrb_installDir="${qbrb_packageDir}/BUILD/${qbrbtools_name}-${qbrbtools_packageVersion}"
qbrb_confFile="$( Qbrbtools_get_config_file "${qbrbtools_packageName}" "install")"

if [ -n "${qbrb_confFile}" ] ; then
  while read line
  do
    fileLine="$( echo "${line}" | sed "s/[ |\\t]\+/ /g" | sed "s/^ //g" | sed "s/ $//g" )"
    if [ -n "${fileLine}" -a "${fileLine:0:1}" != "#" ] ; then
      srcFilePath=$(  echo "${fileLine}" | awk '{print $1}' )
      destFilePath=$( echo "${fileLine}" | awk '{print $2}' )
      if [ -z "${destFilePath}" ] ; then
        echo "ERROR in 'dh_install' - Invalid destination file: '${destFilePath}'"
        exit 1
      fi
      srcFileDir=$( dirname "${srcFilePath}" )
      srcFileName=$( basename "${srcFilePath}" )
      srcContainsMetaChar=$( echo "${srcFileName}" | grep -c "*" )
      if [ ${srcContainsMetaChar} -eq 0 ] ; then
        if [ ! -f "${srcFilePath}" ] ; then
          echo "ERROR in 'dh_install' - File '${srcFilePath}' doesn't exist"
          exit 1
        fi
        destFileDir=$( dirname "${destFilePath}" )
        [ "${destFileDir: -1}" == "/" ] && destFileDir="${destFilePath}"
        mkdir -p "${qbrb_installDir}/${destFileDir}"
        cp -Rf    "${srcFilePath}" "${qbrb_installDir}/${destFilePath}"
      else
        mkdir -p "${qbrb_installDir}/${destFileDir}"
        cp -Rf    "${srcFileDir}"/${srcFileName}  "${qbrb_installDir}/${destFilePath}"
      fi
    fi
  done < "${qbrb_confFile}"
fi

if [ -n "${qbrb_excludedFileList}" ] ; then
  OLD_PWD="${PWD}"
  cd "${qbrb_installDir}"
  for excludedFile in ${qbrb_excludedFileList}
  do
    find . -name "*${excludedFile}*" -exec rm -Rf '{}' \; > /dev/null 2>&1 || true 
  done
  cd "${OLD_PWD}"
fi
