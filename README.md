# bc-marketplace

A Claude Code plugin for searching and installing Boomi Marketplace recipes. Recipes are installed as reference samples — use them to inform how integrations are built, not as production-ready components.

> **Important:** Boomi Companion is a publicly available developer offering, not an officially supported Boomi product. It is provided as-is and is not covered by Boomi support agreements or SLAs. Boomi curates and maintains this tool on a best-effort basis — treat it as a self-service resource. Boomi reserves the right to modify or discontinue it at any time without notice.

This project is licensed under the [BSD-2-Clause License](LICENSE). If you fork or modify this code, you should not use the name "Boomi" for your version.

## Documentation

For a full overview of Boomi Companion, including concepts, usage guidance, and additional resources, see the [Boomi Companion overview](https://developer.boomi.com/docs/BoomiCompanion/Boomi_companion_overview) on the Boomi Developer Portal.

## Related Plugins & Skills

Other plugins available in Boomi Companion:

| Plugin | Description |
|--------|-------------|
| [bc-integration](https://github.com/OfficialBoomi/bc-integration) | Skills, commands, and agents for building Boomi integrations |

The underlying skills are also available as standalone packages for use with other AI agents, or to fork and modify for your own needs:

| Skill | Description |
|--------|-------------|
| [boomi-integration](https://github.com/OfficialBoomi/boomi-integration) | Skill for building Boomi integrations |
| [boomi-marketplace](https://github.com/OfficialBoomi/boomi-marketplace) | Skill for searching and installing Boomi Marketplace recipes |

See the [Boomi Companion marketplace](https://github.com/OfficialBoomi/boomi-companion) for the complete registry.

## Feedback & Issues

Found a bug or have a feature idea? Email developer-offerings@boomi.com with a clear description, steps to reproduce, and any relevant error messages.

## Installation

```bash
/plugin marketplace add OfficialBoomi/boomi-companion
/plugin install bc-marketplace@boomi-companion
```

Or browse and install via `/plugin` interactively.

## Dependencies

- **Search** works standalone — no other plugins required.
- **Install** and **supporting materials download** require the `bc-integration` plugin. Both scripts source `boomi-common.sh` from bc-integration for authentication and activity logging. Folder creation and component pulling also use bc-integration's tools.

## Skill: boomi-marketplace

Search the Boomi Marketplace catalog and install recipes into a target account.

### Workflow

1. **Search** — Query the public GraphQL API for published recipes matching an app or use case (no authentication required).
2. **Install** — Run the install script to deploy a recipe bundle into a `marketplace-imports` subfolder inside a project folder.
3. **Read** — Use bc-integration's component pulling workflow to fetch the installed process XML and its dependencies locally.
4. **Supporting materials** — Run the supporting materials script to save any documents bundled with the recipe (setup guides, PDFs) locally.

### CLI Tools

**Recipe Install** — Installs a marketplace recipe into a target folder:

```bash
BOOMI_COMMON_SH=<path/to/boomi-common.sh> bash <skill-path>/scripts/boomi-marketplace-install.sh --bundle-id <artifactSourceId> --folder-id <numeric_folder_id>
```

Optional: `--target-account-id <ID>` overrides the install target (defaults to `BOOMI_ACCOUNT_ID` from `.env`).

**Supporting Materials Download** — Downloads a recipe bundle and extracts its supporting documents locally (read-only):

```bash
BOOMI_COMMON_SH=<path/to/boomi-common.sh> bash <skill-path>/scripts/boomi-marketplace-supporting-materials.sh --bundle-id <artifactSourceId> --output-dir <dir>
```

### Reference Docs

| Document | Description |
|----------|-------------|
| [GraphQL API](skills/boomi-marketplace/references/graphql-api.md) | Public catalog search queries |
| [Bundle API](skills/boomi-marketplace/references/bundle-api.md) | Authenticated recipe installation and supporting materials download |

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
