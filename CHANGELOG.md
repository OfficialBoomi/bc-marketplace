# Changelog

## 0.2.8

- Skill folder now ships the changelog
- Minor and major version bumps are now honored


## 0.2.7

- Add Documentation and Related Plugins & Skills sections to plugin and skill READMEs


## 0.2.6

- Update feedback email to developer-offerings@boomi.com


## 0.2.5

- Add disclaimer to README clarifying Boomi Companion is a best-effort developer offering, not an officially supported Boomi product


## 0.2.4

- Fix skill sync step to pull latest main before rsync so VERSION stays in sync


## 0.2.3

- Add VERSION file to skill folder, mirror plugin version in pipeline


## 0.2.2

- Pipeline test: no functional changes


## 0.2.1

- Add automated changelog assembly and version bumping via CI pipeline


## 0.2.0

- Add `boomi-marketplace-install.sh` script for recipe installs — credentials are handled via bc-integration's `boomi-common.sh` instead of constructing auth headers inline
- Remove raw credential format from skill documentation and CLAUDE.md
- Activity logging for all install attempts (success and failure)

## 0.1.0

- Initial release — GraphQL catalog search and Bundle API reference docs
