#!/usr/bin/env bash
# Download a Boomi Marketplace bundle and extract its supporting documents. Usage: --help

usage() {
  cat <<'EOF'
Usage: BOOMI_COMMON_SH=/path/to/boomi-common.sh bash <skill-path>/scripts/boomi-marketplace-supporting-materials.sh --bundle-id <ID> --output-dir <DIR>

Downloads a Boomi Marketplace bundle and extracts its supporting documents.

Inputs:
  --bundle-id <ID>     Listing artifactSourceId from the catalog search
  --output-dir <DIR>   Relative path inside the project working directory,
                       e.g. active-development/marketplace-imports/<slug>

Outputs:
  Prints the files in the bundle download, then extracts pdf, doc/docx, ppt/pptx,
  xls/xlsx, md, and txt files into <DIR>. Definition files (YAML, XML, JSON)
  are not extracted.

Side effects:
  Read-only on the Boomi account. Writes only under <DIR>.
  Requires .env in the current directory and bc-integration's boomi-common.sh.
EOF
}

for arg in "$@"; do
  [[ "$arg" == "-h" || "$arg" == "--help" ]] && { usage; exit 0; }
done

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
require_tools curl jq unzip

# --- Parse args ---
BUNDLE_ID=""
OUTPUT_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bundle-id)   BUNDLE_ID="$2"; shift 2 ;;
    --output-dir)  OUTPUT_DIR="$2"; shift 2 ;;
    -*)            echo "Unknown option: $1" >&2; exit 1 ;;
    *)             echo "Unexpected argument: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$BUNDLE_ID" || -z "$OUTPUT_DIR" ]]; then
  echo "Usage: BOOMI_COMMON_SH=/path/to/boomi-common.sh bash <skill-path>/scripts/boomi-marketplace-supporting-materials.sh --bundle-id <ID> --output-dir <DIR>" >&2
  exit 1
fi

# Output must stay inside the project working directory
if [[ "$OUTPUT_DIR" == /* || "$OUTPUT_DIR" == "~"* || "$OUTPUT_DIR" =~ (^|/)\.\.(/|$) ]]; then
  echo "ERROR: --output-dir must be a relative path inside the project working directory (no leading /, ~, or ..)." >&2
  echo "  Use: active-development/marketplace-imports/<slug>" >&2
  exit 1
fi

# Document types to extract
DOC_REGEX='\.(pdf|docx?|pptx?|xlsx?|md|txt)$'

# --- Download bundle ---
url="https://marketplace.boomi.com/bundle-service/v1/bundles/${BUNDLE_ID}/artifacts/download?accountId=${BOOMI_ACCOUNT_ID}"

zipfile=$(mktemp)
trap 'rm -f "$zipfile"' EXIT

echo "Downloading marketplace bundle..."
echo "  Bundle ID: ${BUNDLE_ID}"

code=$(boomi_curl -o "$zipfile" -w "%{http_code}" "$url" \
  -H "Accept: */*" \
  -H "X-Account: ${BOOMI_ACCOUNT_ID}")

if [[ "$code" == "500" ]]; then
  log_activity "marketplace-supporting-materials" "inconclusive" "$code" \
    "$(jq -cn --arg bid "$BUNDLE_ID" '{bundle_id: $bid, note: "no attached files or credentials rejected"}')"
  echo ""
  echo "No supporting materials retrieved (HTTP 500). This bundle may have no attached files, or credentials may have been rejected."
  echo "If the install step also failed, check credentials. If the install succeeded, the bundle has no supporting materials."
  exit 0
fi

if [[ "$code" != "200" || "$(head -c 2 "$zipfile")" != "PK" ]]; then
  log_activity "marketplace-supporting-materials" "fail" "$code" \
    "$(jq -cn --arg bid "$BUNDLE_ID" '{bundle_id: $bid}')"
  echo "ERROR: Download failed (HTTP ${code})" >&2
  exit 1
fi

echo ""
echo "Files in bundle download:"
unzip -Z1 "$zipfile" | sed 's/^/  /'

doc_entries=()
while IFS= read -r entry; do
  doc_entries+=("$entry")
done < <(unzip -Z1 "$zipfile" | grep -iE "$DOC_REGEX")

if [[ ${#doc_entries[@]} -eq 0 ]]; then
  log_activity "marketplace-supporting-materials" "success" "$code" \
    "$(jq -cn --arg bid "$BUNDLE_ID" '{bundle_id: $bid, documents: []}')"
  echo ""
  echo "No supporting documents in this bundle."
  exit 0
fi

# --- Extract supporting documents ---
# -j drops archive paths so entries cannot land outside OUTPUT_DIR
mkdir -p "$OUTPUT_DIR"
if ! unzip -o -q -j "$zipfile" "${doc_entries[@]}" -d "$OUTPUT_DIR"; then
  log_activity "marketplace-supporting-materials" "fail" "$code" \
    "$(jq -cn --arg bid "$BUNDLE_ID" '{bundle_id: $bid, error: "unzip failed"}')"
  echo "ERROR: Failed to extract documents to ${OUTPUT_DIR}" >&2
  exit 1
fi

docs=$(printf '%s\n' "${doc_entries[@]}" | sed 's|.*/||')
log_activity "marketplace-supporting-materials" "success" "$code" \
  "$(jq -cn --arg bid "$BUNDLE_ID" --arg dir "$OUTPUT_DIR" \
     --argjson docs "$(printf '%s\n' "$docs" | jq -R . | jq -s .)" \
     '{bundle_id: $bid, output_dir: $dir, documents: $docs}')"

echo ""
echo "SUCCESS: Supporting documents saved to ${OUTPUT_DIR}:"
printf '%s\n' "$docs" | sed 's/^/  /'
