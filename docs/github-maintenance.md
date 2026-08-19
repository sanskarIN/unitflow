# GitHub repository maintenance

This guide describes repository settings that cannot be fully represented by committed files and explains how those settings should complement the automation that is committed in the repository.

## Default branch protection

For `main`, prefer a ruleset or branch-protection rule that:

- requires pull requests before merge for normal contributor work;
- requires the `Repository integrity`, `Rust quality`, and `Flutter quality` CI jobs once their check names have run successfully and are stable;
- requires appropriate generated-platform smoke jobs for changes that affect supported-platform source/tooling;
- requires branches to be up to date before merge when practical;
- requires conversation resolution;
- blocks force pushes and branch deletion;
- requires review from code owners for sensitive paths when collaboration grows;
- allows repository administrators to recover from emergencies without weakening the everyday rule permanently.

Do not configure a required status check until that exact check name has run successfully at least once; otherwise the branch can become impossible to merge into through normal pull requests.

## Discussions

Enable GitHub Discussions when community Q&A is desired. Suggested categories:

- Announcements
- General
- Ideas
- Q&A
- Show and tell

Bug reports and actionable feature work should remain in Issues so they can be triaged and linked to commits.

## Labels

Recommended labels:

- `bug`
- `enhancement`
- `documentation`
- `dependencies`
- `security`
- `accessibility`
- `performance`
- `rust`
- `flutter`
- `ci`
- `platform: android`
- `platform: windows`
- `platform: linux`
- `platform: macos`
- `platform: web`
- `platform: ios`
- `good first issue`
- `help wanted`
- `blocked`

Avoid labels that duplicate issue state without adding useful triage information.

## Milestones

Use milestones for release-oriented work rather than every small internal task. Suggested near-term milestones:

1. `0.1.0-alpha.1` — conversion/product baseline plus repository/release hardening.
2. `0.2.0-alpha` — production native bridge and reviewed platform scaffolding.
3. `0.3.0-beta` — native packaging, end-to-end tests, performance/accessibility audits.
4. `1.0.0` — supported-platform release verification and documentation freeze.

Milestones describe planning; the actual package version remains controlled by repository metadata and must satisfy the release-consistency/tag validators.

## Security settings

When available for the public repository, enable:

- private vulnerability reporting;
- secret scanning and push protection;
- dependency graph;
- Dependabot alerts;
- security updates.

The repository contains CodeQL, pull-request dependency review, repository-hygiene validation, and `.github/dependabot.yml` update configuration for Cargo, Flutter/Dart, and GitHub Actions. Security findings should be triaged before release rather than hidden by disabling checks.

## Dependabot review

Dependabot update pull requests are proposals, not trusted automatic upgrades. Require the same review appropriate to a manual dependency change, including manifest/lockfile inspection, repository CI, and relevant native platform checks. Do not enable unconditional auto-merge for dependency updates.

## Workflow permissions

Keep workflow permissions least-privileged. Normal CI and platform-smoke workflows should remain read-only unless a concrete write is required. The release workflow needs `contents: write` because it creates GitHub releases; changes to that workflow deserve security-sensitive review.

## Merge strategy

Prefer squash merge for noisy external contribution branches or merge commits when preserving a carefully structured multi-commit feature history is valuable. Do not rewrite the protected default branch simply to make history look cleaner.

## Periodic maintenance

Periodically review:

- required status-check names after workflow refactors;
- stale Actions/dependency versions;
- branch/ruleset effectiveness;
- open Dependabot/security findings;
- repository collaborators and permissions;
- release tags/assets for accidental drift;
- issue templates, support addresses, and vulnerability-reporting settings.
