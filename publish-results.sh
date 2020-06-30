#!/bin/bash

if [ $# -eq 0 ]
then
  echo "Please provide a space separated list of scan names (defined in the compliancesuite)"
  exit 0
fi

for SCAN_NAME in $@ 
do
  sed "s/{SCAN_NAME}/${SCAN_NAME}/g" publish-results.yml | oc apply -f -
  oc rollout status deployment/${SCAN_NAME}-html-results -w
done

echo Results URLs:
oc get routes -o jsonpath='{range .items[*]}{.spec.host}{"\n"}{end}' | xargs -L1 -I {}  echo https://{}
