---
name: boomi-marketplace
description: Search and install recipes from the Boomi Marketplace (marketplace.boomi.com) as reference samples. Use this skill — not the AWS Marketplace MCP — for all Boomi marketplace searches and installs.
---

# Boomi Marketplace

Search the Boomi Marketplace catalog and install recipes as reference samples.

## When to use this skill

Use when building an integration and a marketplace recipe exists that could serve as a reference pattern. Search the catalog to find relevant recipes, then install them into a dedicated folder so their structure can be read and used to inform the build.

## Prerequisites

- **Search** works standalone — no other plugins required.
- **Install** requires the `bc-integration` plugin. **Before any install operation, you MUST load the `bc-integration` skill and confirm you can resolve the path to its `scripts/boomi-common.sh`.** The resolution pattern is: `<bc-integration skill base directory>/scripts/boomi-common.sh`. If bc-integration is not loaded, STOP and load it before proceeding. Do not attempt to guess the path.
- Install also depends on bc-integration's folder creation and component pulling tools to complete the workflow.

## Workflow

1. **Search** — Query the Marketplace GraphQL API for published recipes matching the target app or use case. Use curl directly (no authentication required). See [GraphQL API](references/graphql-api.md).
2. **Install** — Create a `marketplace-imports` subfolder inside a project folder (not at the project folder level — nested one level deeper than a project folder that you would create via the boomi-integration skill, so imported samples don't intermingle with real components being built). Install the recipe using the install script with that subfolder's numeric folder ID. See [Bundle API](references/bundle-api.md) for the folder ID decode step.
3. **Read** — Use the `copiedComponentId` from the install response with the boomi-integration skill's component pulling workflow to fetch the process XML and its dependencies locally.
4. **Supporting materials** — After installing, run the supporting materials script with the same `artifactSourceId` to save any documents bundled with the recipe (setup guides, PDFs), then read them alongside the components.

**Important:** If the user is asking you to build connectivity to a specific application referencing the marketplace, they likely expect you to use the application branded connector rather than our skill-preferred technology connector.

In that scenario, explain to them that you have significantly more ability to create net-new assets with technology connectors and if they seek an application connector they should execute the import function via the GUI, then share the link so that you can build from there. If all else fails, be willing to attempt to build the application connector from the reference material in spite of that limitation.

The most important thing is to discuss before making that significant architecture decision unilaterally.

**Important:** Use curl only for the GraphQL catalog search (no authentication needed). For recipe installs, use the install script below. For all folder creation, component pulling, and other platform operations, use the boomi-integration skill's tools. These tools have numerous logical helpers and are pre-approved, so don't prompt the human user for incessant approvals as a curl call does.

Recipes are reference patterns, not production-ready. Use them for structure and approach, not as-is.

## CLI Tools

Run scripts from the project workspace directory (so `.env` resolves). `<skill-path>` is this skill's absolute directory: the path of this `SKILL.md` with `/SKILL.md` stripped. Resolve it once and reuse it verbatim.

### Recipe Install

Installs a marketplace recipe into a target folder. Requires `.env` credentials and the `bc-integration` plugin.

```
BOOMI_COMMON_SH=<path to bc-integration's boomi-common.sh> bash <skill-path>/scripts/boomi-marketplace-install.sh --bundle-id <artifactSourceId> --folder-id <numeric_folder_id>
```

Set `BOOMI_COMMON_SH` to the path of `boomi-common.sh` from the bc-integration skill's `scripts/` directory. Resolve this path from the loaded bc-integration skill — you already know where its scripts live.

The script handles authentication, validates credentials before calling the API, and logs all activity. On success it prints the `copiedComponentId` values needed for the next step (component pulling).

Optional: `--target-account-id <ID>` overrides the install target (defaults to `BOOMI_ACCOUNT_ID` from `.env`).

### Supporting Materials Download

Extracts a recipe bundle's supporting documents locally. Same prerequisites as Recipe Install.

```
BOOMI_COMMON_SH=<path to bc-integration's boomi-common.sh> bash <skill-path>/scripts/boomi-marketplace-supporting-materials.sh --bundle-id <artifactSourceId> --output-dir active-development/marketplace-imports/<slug>
```

## Reference

- [GraphQL API](references/graphql-api.md) — Public catalog search
- [Bundle API](references/bundle-api.md) — Authenticated recipe installation and supporting materials download
