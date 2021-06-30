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
qbrb_postInstFile="$( Qbrbtools_get_config_file "${qbrbtools_packageName}" "postinst")"
if [ -z "${qbrb_postInstFile}"  ] ; then
  qbrb_postInstFile="${PWD}/${qbrbtools_distribDir}/${qbrbtools_packageName}.postinst"
  cat<<EOF > "${qbrb_postInstFile}"
#!/usr/bin/env bash

#DEBHELPER#
exit 0
EOF
fi

qbrb_dirsConfigFile=$( Qbrbtools_get_config_file "${qbrbtools_packageName}" "dirs")
if [[ -n "${qbrb_dirsConfigFile}" ]] ; then
  # remove tabs and extra spaces
  sed -i 's/\\t/ /g' "${qbrb_dirsConfigFile}"
  while read line
  do
    dirList=$( echo "${line}" | sed "s/[ |\\t]\+/ /g" | sed "s/^ //g" | sed "s/ $//g" )
    if [ -n "${dirList}" ] ; then
      for curDir in ${dirList}
      do
        mkdir -p "${qbrb_installDir}/${curDir}"
      done
    fi
  done < "${qbrb_dirsConfigFile}"
fi

