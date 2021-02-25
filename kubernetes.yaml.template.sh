#!/usr/bin/env bash

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euo pipefail

# Set the image tag if not set
if [ -z "${IMAGE_TAG:-}" ]; then
    IMAGE_TAG=$(git rev-parse HEAD)
fi

# Temporary directory for customisations
TEMPDIR=$(mktemp -d tmp.k8s.XXXXX)

# Delete the temporary directory when the script exits
delete_temp_dir() {
    if [ -d "${TEMPDIR}" ]; then
        rm -r "${TEMPDIR}"
    fi
}
trap delete_temp_dir EXIT

# Check if kustomize CLI tool exists
if command -v kustomize >/dev/null; then
    (
        cd "${TEMPDIR}"
        kustomize create --resources ../k8s-base
        kustomize edit set image "myapp=gitlab.novanoweb.com/novanowebplatform/services/tenant-service.git:${IMAGE_TAG}"
        kustomize build . > deployment.yaml
        cp deployment.yaml ../manifests
        git add -- ../manifests

    )
    exit
fi
 
# If the kustomize CLI tool doesn't exist,
# we create the temporary project using plain files instead.
# Create a kustomization.yaml file that uses
# the other Kustomize directory as a base.
#cat <<EOF > "${TEMPDIR}/kustomization.yaml"
#bases:
#- ../k8s-base
#images:
#- name: myapp
#  newName: gitlab.novanoweb.com/novanowebplatform/services/tenant-service.git
#  newTag: "${IMAGE_TAG}"
#EOF

## Render the temporary Kustomize directory as YAML manifests.
# These can be piped directory to kubectl apply -f
#kubectl kustomize "${TEMPDIR}"
#git -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" $CI_REGISTRY
#git add  "${TEMPDIR}"
#git commit && git push


## - !/bin/bash -e
#commit_message="$1"
#git add . -A
#git commit -m "$commit_message"
#git push