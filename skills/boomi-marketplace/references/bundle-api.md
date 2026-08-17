# Bundle Service API

Authenticated API for installing marketplace recipes into a Boomi account.

**Do not call this API directly.** Use `scripts/boomi-marketplace-install.sh` for all installs. The script handles authentication via bc-integration's `boomi-common.sh` and logs all activity. See the CLI Tools section in SKILL.md.

**Important:** Repeated invalid API attempts in a narrow window will cause the user to be locked out of the platform API and GUI until they reset their password. Be precise with auth and query formatting.

**Important:** DO NOT delete installed components or folders as cleanup. Installed recipes are lightweight and harmless. Deletion risks removing the wrong assets and provides no meaningful benefit.

## Endpoint

```
POST https://platform.boomi.com/bundle-service/v1/bundles/installations?accountId={BOOMI_ACCOUNT_ID}
Content-Type: application/json
x-boomi-bundle-source: boomi-companion
```

## Headers

| Header | Required | Notes |
|--------|----------|-------|
| `Content-Type` | Yes | `application/json` |
| `x-boomi-bundle-source` | No | Identifies Boomi Companion as the installer. |

## Authentication

Handled by the install script via bc-integration's `boomi-common.sh`. Do not construct auth headers manually.

## Request

```json
{
  "bundleId": "<artifactSourceId from GraphQL>",
  "targetAccountId": "<BOOMI_ACCOUNT_ID>",
  "folderId": "<numeric folder ID>"
}
```

| Field | Required | Notes |
|-------|----------|-------|
| `bundleId` | Yes | The `artifactSourceId` from the catalog listing |
| `targetAccountId` | Yes | Account to install into |
| `folderId` | No | Numeric folder ID (e.g. `7989067`). Must be plain numeric — Base64-encoded Platform API format (`Rjo3OTg5MDY3`) is rejected. Decode with: base64 decode → strip `F:` prefix → use numeric portion. |
| `folderName` | No | Creates a single folder with this literal name. Slashes are part of the name, not path separators — `a/b` creates one folder named `a/b`, not `a` containing `b`. Ignored entirely when `folderId` is provided. |

### Install checklist

- Create the project folder under `BOOMI_FOLDER_ID` using the boomi-integration skill (if not already created for the build)
- Create a `marketplace-imports` subfolder INSIDE that project folder — this keeps imported recipes separate from components being built
- Decode the subfolder's Base64 ID to numeric: `echo "<Base64 ID>" | base64 -d` → `F:8403439` → strip `F:` → `8403439`
- Pass the numeric ID as `folderId` in the install request

## Response

```json
{
  "resultCode": "OK",
  "data": {
    "installationStatus": "SUCCESS",
    "bundleName": "Connect Coupa to VersaPay",
    "artifactInstallationResults": [
      {
        "installationStatus": "SUCCESS",
        "artifactType": "PACKAGED_COMPONENT",
        "copiedComponentId": "783e3c22-...",
        "copiedComponentVersion": 1,
        "folderId": "1242888"
      }
    ]
  }
}
```

**Always check `installationStatus`** — HTTP 200 does not guarantee success. Possible values: `SUCCESS`, `PARTIAL`, `FAILURE`, `UNDEFINED`.

The `copiedComponentId` in each artifact result is the installed component ID, readable via the Platform API.

## Scope

This skill covers integration recipe installation (artifact type `PACKAGED_COMPONENT`). The Bundle Service also supports Boomi Flow and other platform services, but installation and usage for those differ and are not covered here.