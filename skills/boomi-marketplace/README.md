# boomi-marketplace Skill

Search and install Boomi Marketplace recipes as reference samples for AI-assisted integration development. The intended audience of this README.md document is humans seeking to understand the skill.

> **Important:** Boomi Companion is a publicly available developer offering, not an officially supported Boomi product. It is provided as-is and is not covered by Boomi support agreements or SLAs. Boomi curates and maintains this tool on a best-effort basis — treat it as a self-service resource. Boomi reserves the right to modify or discontinue it at any time without notice.

This project is licensed under the [BSD-2-Clause License](LICENSE). If you fork or modify this code, you should not use the name "Boomi" for your version.

## Documentation

For a full overview of Boomi Companion, including concepts, usage guidance, and additional resources, see the [Boomi Companion overview](https://developer.boomi.com/docs/BoomiCompanion/Boomi_companion_overview) on the Boomi Developer Portal.

## Related Plugins & Skills

This skill is also part of [Boomi Companion](https://github.com/OfficialBoomi/boomi-companion), which includes the following Claude Code plugins:

| Plugin | Description |
|--------|-------------|
| [bc-integration](https://github.com/OfficialBoomi/bc-integration) | Skills, commands, and agents for building Boomi integrations |
| [bc-marketplace](https://github.com/OfficialBoomi/bc-marketplace) | Skill for searching and installing Boomi Marketplace recipes |

Other skills available as standalone packages for use with other AI agents:

| Skill | Description |
|--------|-------------|
| [boomi-integration](https://github.com/OfficialBoomi/boomi-integration) | Skill for building Boomi integrations |

## Feedback & Issues

Found a bug or have a feature idea? Email developer-offerings@boomi.com with a clear description, steps to reproduce, and any relevant error messages.

## What is this?

A distributable skill that provides AI coding agents with knowledge and tooling for working with the Boomi Marketplace catalog. It enables:

- Searching the public Boomi Marketplace for published recipes matching an app or use case
- Installing recipe bundles into a target Boomi account as reference samples
- Activity logging for all install attempts

Recipes are reference patterns, not production-ready components. Use them for structure and approach when building integrations.

## Prerequisites

- `curl` (universally available)
- `jq` (install via `brew install jq` on macOS or `apt install jq` on Linux)

### For installs only

- The `bc-integration` plugin must be installed and its skill loaded — the install script sources `boomi-common.sh` from bc-integration for authentication, credential validation, and activity logging.
- A configured `.env` file in your project root with Boomi platform API credentials (see the boomi-integration skill README for details).

## Installation

### Claude Code (via the bc-marketplace plugin)

Install through the Claude Code plugin system — the skill is included automatically:

1. Add the Boomi marketplace: `/plugin marketplace add OfficialBoomi/boomi-companion`
2. Install the plugin: `/plugin install bc-marketplace@boomi-companion`

Alternatively, navigate the `/plugin` menu interactively within Claude Code to add the marketplace and install.

### Manual configuration

Clone or copy this skill directory into the location your platform uses for agent skills. Consult your platform's documentation for the correct skill directory path.

## Usage

### Workflow

1. **Search** — Describe what you're building. The agent queries the Marketplace GraphQL API for matching recipes (no authentication required).
2. **Install** — The agent creates a `marketplace-imports` subfolder inside a project folder and runs the install script to deploy the recipe bundle there.
3. **Read** — The agent uses bc-integration's component pulling workflow to fetch the installed process XML and its dependencies locally for review.

### Example Workflow

```
You: "Find a marketplace recipe for Salesforce to NetSuite integration"

Agent: [Searches the Marketplace GraphQL API]
       [Presents matching recipes with descriptions]

You: "Install that one as a reference"

Agent: [Creates marketplace-imports folder]
       [Runs install script with the recipe's bundle ID]
       [Pulls installed components locally via bc-integration]
       [Reviews the process structure to inform the build]
```

## Tools Overview

The skill makes the following CLI tool available to the agent:

- `boomi-marketplace-install.sh` — Installs a marketplace recipe bundle into a target folder. Handles authentication via bc-integration's shared infrastructure, validates credentials before calling the API, and logs all activity.

```
BOOMI_COMMON_SH=<path/to/boomi-common.sh> bash scripts/boomi-marketplace-install.sh --bundle-id <artifactSourceId> --folder-id <numeric_folder_id>
```

Optional: `--target-account-id <ID>` overrides the install target (defaults to `BOOMI_ACCOUNT_ID` from `.env`).

## Documentation Structure

The skill includes the following reference documentation:

- [GraphQL API](references/graphql-api.md) — Public catalog search queries and response format
- [Bundle API](references/bundle-api.md) — Authenticated recipe installation via the Bundle Service API

## Support and Issues

This skill is designed originally for Claude Code, but Agent Skills are an open standard accessible to other models and platforms.

More info about agent skills can be found here: https://agentskills.io/home
and here: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview

If you encounter issues:

1. This course provides an excellent intro to Claude Code: https://anthropic.skilljar.com/claude-code-in-action
2. We would love your feedback and input via developer-offerings@boomi.com
3. Your AI agent can often help troubleshoot and explain issues
