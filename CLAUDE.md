# bc-marketplace

Claude Code plugin for searching and installing Boomi Marketplace recipes. Installs recipe bundles into a target account as reference samples that can inform how integrations are built.

## Installation

```bash
/plugin marketplace add git@bitbucket.org:officialboomi/boomi-marketplace.git
/plugin install bc-marketplace@boomi-marketplace
```

Requires `boomi-integration` plugin for recipe installs. The install script sources `boomi-common.sh` from bc-integration for authentication and activity logging. Catalog search works standalone. This plugin also depends on bc-integration's folder management, component pulling tools, and platform knowledge to complete its workflow.

## Versioning

`CHANGELOG.md` and the `version` field in `.claude-plugin/plugin.json` are managed by CI on merge to main. Do not edit them directly.

To record a change, create a file in `changes/` named after the branch (if the branch contains a `/`, use only the part after the slash). Content is the changelog entry with `- ` prefix:

```
- Add support for new feature
```

## Structure

```
.claude-plugin/plugin.json
skills/
  boomi-marketplace/
    SKILL.md
    scripts/
      boomi-marketplace-install.sh
      boomi-marketplace-supporting-materials.sh
    references/
      graphql-api.md
      bundle-api.md
```