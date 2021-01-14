#!/bin/bash
# Version: 0.4
# Maintainer: @pgold30
# Repo: https://github.com/pgold30/janos-k8s-migration-tool/

#SEARCHPATH=$1
echo "insert full path where yamls files exist"
read SEARCHPATH

echo "enter version of K8s for which you want to validate the yaml files(default 1.16.0)"
read kubeversion

usage () {
  local errorMessage=$1
  echo
  echo "---------------------------------------------------------------"
  echo "Error: $errorMessage"
  echo "---------------------------------------------------------------"
  echo "usage: ./janos.sh <path to manifests>"
  echo "  e.g. ./janos.sh /tmp/my-yamls"
  echo "---------------------------------------------------------------"
  exit 1
}

if [ -z "$SEARCHPATH" ]
then
  usage "No target directory specified"
fi

function replace_deprecated_apis {
  # Find all depreciation targets
  mapfile -t files < <(grep -liEr "kind: Deployment|kind: Daemonset|kind: Statefulset|kind: ReplicaSet" "$SEARCHPATH")
  for i in "${files[@]}"; do
          if [[ `grep -E "extensions/v1beta1|apps/v1beta2|apps/v1beta1" "$i"` ]]; then
                  echo "Deprecated API found in [$i].. Transmogrifying..."
                  sed -i -e "s|extensions/v1beta1|apps/v1|" "$i"
                  sed -i -e "s|apps/v1beta2|apps/v1|" "$i"
                  sed -i -e "s|apps/v1beta1|apps/v1|" "$i"
          fi
  done

  mapfile -t files < <(grep -liEr "kind: PodSecurityPolicy" "$SEARCHPATH")
  for i in "${files[@]}"; do
          if [[ `grep -E "extensions/v1beta1|apps/v1beta2" "$i"` ]]; then
                  echo "Deprecated API found in [$i].. Transmogrifying..."
                  sed -i -e "s|extensions/v1beta1|policy/v1beta1|" "$i"
          fi
  done
}
# This funtion will add the mandatatory field spec.selector on each yaml file , using name as that value
function add_spec-selector () {
  FILE=$1
  export METADATANAME=$(yq eval '.metadata.name' $FILE)
  yq -i eval '.spec.selector.matchLabels.app |= env(METADATANAME)' $FILE
}

# This funtion will validate the resulting file for the given K8s version
function validate {
  FILE=$1
  cat $FILE | kubeval --kubernetes-version $kubeversion
}

for file in $(find $SEARCHPATH -name '*.yaml' -or -name '*.yml');
do
  echo "1:Replacing all deprecated APIs for K8s 1.16..."
  replace_deprecated_apis $file
  echo "2:Generating required spec.selector for $file..."
  add_spec-selector $file
  echo "3:Validating file for K8s specified version with kubeval..."
  validate $file
done
