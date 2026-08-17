#!/usr/bin/env bash
# Install a Boomi Marketplace recipe via the Bundle Service API
# Usage: BOOMI_COMMON_SH=/path/to/boomi-common.sh bash scripts/boomi-marketplace-install.sh --bundle-id <ID> --folder-id <NUMERIC_ID> [--target-account-id <ID>]

# --- Source shared infrastructure from bc-integration ---
if [[ -z "${BOOMI_COMMON_SH:-}" ]]; then
  echo "ERROR: BOOMI_COMMON_SH not set." >&2
  echo "Load the bc-integration skill first, then resolve the path from:" >&2
  echo "  <bc-integration skill base directory>/scripts/boomi-common.sh" >&2
  exit 1
fi
if [[ ! -f "$BOOMI_COMMON_SH" ]]; then
  echo "ERROR: boomi-common.sh not found at: $BOOMI_COMMON_SH" >&2
  echo "The path may be wrong. Verify bc-integration's skill base directory and set:" >&2
  echo "  BOOMI_COMMON_SH=<bc-integration skill base directory>/scripts/boomi-common.sh" >&2
  exit 1
fi
source "$BOOMI_COMMON_SH"

load_env
require_env BOOMI_USERNAME BOOMI_API_TOKEN BOOMI_ACCOUNT_ID
require_tools curl jq

# --- Parse args ---
BUNDLE_ID=""
FOLDER_ID=""
TARGET_ACCOUNT_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bundle-id)          BUNDLE_ID="$2"; shift 2 ;;
    --folder-id)          FOLDER_ID="$2"; shift 2 ;;
    --target-account-id)  TARGET_ACCOUNT_ID="$2"; shift 2 ;;
    -*)                   echo "Unknown option: $1" >&2; exit 1 ;;
    *)                    echo "Unexpected argument: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$BUNDLE_ID" || -z "$FOLDER_ID" ]]; then
  echo "Usage: BOOMI_COMMON_SH=/path/to/boomi-common.sh bash scripts/boomi-marketplace-install.sh --bundle-id <ID> --folder-id <NUMERIC_ID> [--target-account-id <ID>]" >&2
  exit 1
fi

[[ -z "$TARGET_ACCOUNT_ID" ]] && TARGET_ACCOUNT_ID="$BOOMI_ACCOUNT_ID"

# --- Install recipe ---
url="https://platform.boomi.com/bundle-service/v1/bundles/installations?accountId=${BOOMI_ACCOUNT_ID}"

body=$(jq -n \
  --arg bid "$BUNDLE_ID" \
  --arg tid "$TARGET_ACCOUNT_ID" \
  --arg fid "$FOLDER_ID" \
  '{bundleId: $bid, targetAccountId: $tid, folderId: $fid}')

echo "Installing marketplace recipe..."
echo "  Bundle ID: ${BUNDLE_ID}"
echo "  Folder ID: ${FOLDER_ID}"
echo "  Target account: ${TARGET_ACCOUNT_ID}"

boomi_api -X POST "$url" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "x-boomi-bundle-source: boomi-companion" \
  -d "$body"

if [[ "$RESPONSE_CODE" != "200" && "$RESPONSE_CODE" != "201" ]]; then
  log_activity "marketplace-install" "fail" "$RESPONSE_CODE" \
    "$(jq -cn --arg bid "$BUNDLE_ID" --arg fid "$FOLDER_ID" \
       --arg err "${RESPONSE_BODY:0:500}" \
       '{bundle_id: $bid, folder_id: $fid, error: $err}')"
  echo "ERROR: Install failed (HTTP ${RESPONSE_CODE}): ${RESPONSE_BODY}" >&2
  exit 1
fi

# HTTP 200 does not guarantee success — check installationStatus
install_status=$(echo "$RESPONSE_BODY" | jq -r '.data.installationStatus // "UNKNOWN"')

if [[ "$install_status" != "SUCCESS" ]]; then
  log_activity "marketplace-install" "fail" "$RESPONSE_CODE" \
    "$(jq -cn --arg bid "$BUNDLE_ID" --arg fid "$FOLDER_ID" \
       --arg status "$install_status" --arg body "${RESPONSE_BODY:0:500}" \
       '{bundle_id: $bid, folder_id: $fid, installation_status: $status, response: $body}')"
  echo "ERROR: Install returned status '${install_status}' (HTTP ${RESPONSE_CODE})" >&2
  echo "$RESPONSE_BODY" | jq '.' 2>/dev/null || echo "$RESPONSE_BODY"
  exit 1
fi

# Extract results
bundle_name=$(echo "$RESPONSE_BODY" | jq -r '.data.bundleName // "unknown"')
log_activity "marketplace-install" "success" "$RESPONSE_CODE" \
  "$(jq -cn --arg bid "$BUNDLE_ID" --arg fid "$FOLDER_ID" \
     --arg name "$bundle_name" --arg status "$install_status" \
     --argjson ids "$(echo "$RESPONSE_BODY" | jq '[.data.artifactInstallationResults[]?.copiedComponentId]')" \
     '{bundle_id: $bid, folder_id: $fid, bundle_name: $name, installation_status: $status, copied_component_ids: $ids}')"

echo "SUCCESS: Installed '${bundle_name}'"
echo ""
echo "Copied component IDs:"
echo "$RESPONSE_BODY" | jq -r '.data.artifactInstallationResults[]? | "  \(.copiedComponentId) (v\(.copiedComponentVersion // "?"))"'
