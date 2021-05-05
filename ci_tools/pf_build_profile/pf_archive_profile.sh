#!/usr/bin/env sh
set -x
_initialDir="${PWD}"
_scriptDir="${PWD}/ci_tools/pf_build_profile"

cd "${_scriptDir}" || exit

test "${1}" == "-B" && _backup=true

prop() {
  grep "${1}" env.properties|cut -d'=' -f2
}
# shellcheck source=../ci_tools.lib.sh
. ../ci_tools.lib.sh
set +a
set -x

getPfVars

pVersion="$(git rev-parse --short HEAD)_zip"

echo "Creating output folder..."
mkdir -p "${pVersion}"
export pVersion

echo "Downloading data archive from ${PF_ADMIN_PUBLIC_HOSTNAME}..."
curl -X GET --basic -u kumar:Lms@12345 --header 'Content-Type: application/zip' --header 'X-XSRF-Header: PingFederate' "https://${PF_ADMIN_PUBLIC_HOSTNAME}/pf-admin-api/v1/configArchive/export" --insecure --output  "${pVersion}/data.zip"

#getGlobalVars | awk '{ print length($0) " " $0; }' | sort -r -n | cut -d ' ' -f 2- > tmpHosts
echo "Variablize the Data Archive"
./variablize.sh -p "${pVersion}/data.zip" -e hosts -B 
echo "#### ENV VARS #####" >> "${pVersion}/env_vars"
#cat tmpHosts >> "${pVersion}/env_vars"
cat hosts >> "${pVersion}/env_vars"


