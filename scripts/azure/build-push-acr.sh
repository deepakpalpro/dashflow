#!/usr/bin/env bash
# Build platform + pipelet + mock images and push to Azure Container Registry.
#
# Usage:
#   ./scripts/azure/build-push-acr.sh <acrName> [tag]
# Example:
#   ./scripts/azure/build-push-acr.sh dfdevacrxxxx 0.1.0
#
# Prerequisites: az login, docker, az acr login permission.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ACR_NAME="${1:-}"
TAG="${2:-0.1.0}"

if [[ -z "$ACR_NAME" ]]; then
  printf 'Usage: %s <acrName> [tag]\n' "$(basename "$0")" >&2
  exit 1
fi

if ! command -v az >/dev/null 2>&1; then
  echo "ERROR: az CLI required" >&2
  exit 1
fi
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker required" >&2
  exit 1
fi

LOGIN_SERVER="$(az acr show -n "$ACR_NAME" --query loginServer -o tsv)"
echo "ACR login server: $LOGIN_SERVER"
az acr login -n "$ACR_NAME"

build_push() {
  local dockerfile="$1"
  local context="$2"
  local image="$3"
  local full="${LOGIN_SERVER}/${image}:${TAG}"
  echo "==> Building $full"
  docker build -f "$dockerfile" -t "$full" "$context"
  docker push "$full"
  # Also tag unprefixed local name for kustomize edit convenience
  docker tag "$full" "${image}:${TAG}"
}

cd "$ROOT"

# Platform
build_push dashflow-api/Dockerfile . "dashflow/api"
build_push dashflow-ui/Dockerfile . "dashflow/ui"

# Mocks
build_push mockservice/petstore/Dockerfile mockservice/petstore "dashflow/petstore"
build_push mockservice/petstore-inventory/Dockerfile mockservice/petstore-inventory "dashflow/petstore-inventory"

# Pipelets (Jobs created by API) — nested source|transformer|destination/<group>/<id>
while IFS= read -r _df; do
  _p="$(basename "$(dirname "$_df")")"
  build_push "$_df" pipelets "dashflow/${_p}"
done < <(
  find pipelets/source pipelets/transformer pipelets/destination \
    -mindepth 2 -maxdepth 2 -type d -name 'plet-*' -exec test -f '{}/Dockerfile' \; \
    -print 2>/dev/null | sort | while read -r _d; do printf '%s/Dockerfile\n' "$_d"; done
)

# Optional composite demo pipelet
if [[ -f pipelets/inventory/Dockerfile ]]; then
  build_push pipelets/inventory/Dockerfile pipelets/inventory "dashflow/inventory-pipelet"
fi

cat <<EOF

Pushed images to ${LOGIN_SERVER} with tag ${TAG}.

Next:
  ./scripts/azure/apply-aks.sh ${ACR_NAME} ${TAG}

Pipelet image pattern for API:
  ${LOGIN_SERVER}/dashflow/{pipeletId}:${TAG}
EOF
