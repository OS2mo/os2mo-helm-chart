#!/usr/bin/env bash

# SPDX-FileCopyrightText: Magenta ApS
#
# SPDX-License-Identifier: MPL-2.0

KIND="${KIND:-kind}"
KUBECTL="${KUBECTL:-kubectl}"

if ! command -v "${KIND}" &> /dev/null; then
    echo "'kind' could not be found"
    exit 1
fi
if ! command -v "${KUBECTL}" &> /dev/null; then
    echo "'kubectl' could not be found"
    exit 1
fi
OS2MO_CLUSTER_EXISTS=$(${KIND} get clusters | grep "os2mo")
if [ -z "${OS2MO_CLUSTER_EXISTS}" ]; then
    ${KIND} create cluster --config=cluster-config.yaml --name os2mo
    echo ""
fi

# Ensure we bail if anything fails from now on. In particular, we do NOT want
# the `use-context` to fail and apply on an arbitrary cluster.
set -e
kubectl config use-context kind-os2mo
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

helm repo add mittwald https://helm.mittwald.de
helm upgrade --install kubernetes-secret-generator \
    --namespace=secret-generator \
    --create-namespace \
    mittwald/kubernetes-secret-generator

helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install cnpg \
    --namespace=cnpg-system \
    --create-namespace \
    cnpg/cloudnative-pg
