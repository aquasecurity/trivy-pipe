#!/usr/bin/env bash

set -e

scanType=$(echo $scanType | tr -d '\r')
export artifactRef="${imageRef}"
if [ "${scanType}" = "fs" ] ||  [ "${scanType}" = "config" ];then
  if [ $scanRef ]; then
    artifactRef=$BITBUCKET_CLONE_DIR/scanRef
  else
    artifactRef=$BITBUCKET_CLONE_DIR
  fi
fi
input=$(echo $input | tr -d '\r')
if [ $input ]; then
  artifactRef="--input $input"
fi
ignoreUnfixed=$(echo $ignoreUnfixed | tr -d '\r')
hideProgress=$(echo $hideProgress | tr -d '\r')

GLOBAL_ARGS=""
if [ $cacheDir ];then
  GLOBAL_ARGS="$GLOBAL_ARGS --cache-dir $cacheDir"
fi

SARIF_ARGS=""
ARGS=""
if [ $format ];then
 ARGS="$ARGS --format $format"
fi
if [ $template ] ;then
 ARGS="$ARGS --template $template"
fi
if [ $exitCode ];then
 ARGS="$ARGS --exit-code $exitCode"
fi
if [ "$ignoreUnfixed" == "true" ] && [ "$scanType" != "config" ];then
  ARGS="$ARGS --ignore-unfixed"
  SARIF_ARGS="$SARIF_ARGS --ignore-unfixed"
fi
if [ $vulnType ] && [ "$scanType" != "config" ];then
  ARGS="$ARGS --vuln-type $vulnType"
  SARIF_ARGS="$SARIF_ARGS --vuln-type $vulnType"
fi
if [ $severity ];then
  ARGS="$ARGS --severity $severity"
fi
if [ $output ];then
  ARGS="$ARGS --output $output"
fi
if [ $skipDirs ];then
  for i in $(echo $skipDirs | tr "," "\n")
  do
    ARGS="$ARGS --skip-dirs $i"
    SARIF_ARGS="$SARIF_ARGS --skip-dirs $i"
  done
fi
if [ $timeout ];then
  ARGS="$ARGS --timeout $timeout"
fi
if [ $ignorePolicy ];then
  ARGS="$ARGS --ignore-policy $ignorePolicy"
  SARIF_ARGS="$SARIF_ARGS --ignore-policy $ignorePolicy"
fi
if [ "$hideProgress" == "true" ];then
  ARGS="$ARGS --no-progress"
fi

echo "Running trivy with options: ${ARGS}" "${artifactRef}"
echo "Global options: " "${GLOBAL_ARGS}"
trivy $GLOBAL_ARGS ${scanType} $ARGS ${artifactRef} 
returnCode=$?

# SARIF is special. We output all vulnerabilities,
# regardless of severity level specified in this report.
# This is a feature, not a bug :)
if [[ ${template} == *"sarif"* ]]; then
  echo "Building SARIF report with options: ${SARIF_ARGS}" "${artifactRef}"
  trivy --quiet ${scanType} --format template --template ${template} --output ${output} $SARIF_ARGS ${artifactRef} $BITBUCKET_CLONE_DIR
fi

exit $returnCode
