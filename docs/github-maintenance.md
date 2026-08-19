# GitHub repository maintenance

This guide describes repository settings that cannot be fully represented by committed files.

## Default branch protection

For `main`, prefer a ruleset or branch-protection rule that:

- requires pull requests before merge for normal contributor work;
- requires the `Rust quality` and `Flutter quality` CI jobs once their check names are stable;
- requires branches to be up to date before merge when practical;
- requires conversation resolution;
- blocks force pushes and branch deletion;
- requires review from code owners for sensitive paths when collaboration grows;
- allows repository administrators to recover from emergencies without weakening the everyday rule permanently.

Do not configure required checks until each named workflow has run successfully at least once; otherwise the branch can become impossible to merge into through normal pull requests.

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

1. `0.1.0-alpha` — core conversion, persistence, batch, history, documentation baseline.
2. `0.2.0-alpha` — native bridge and generated platform scaffolding.
3. `0.3.0-beta` — platform packaging, end-to-end tests, accessibility audit.
4. `1.0.0` — supported-platform release verification and documentation freeze.

## Security settings

When available for the public repository, enable:

- private vulnerability reporting;
- secret scanning and push protection;
- dependency graph;
- Dependabot alerts;
- automated dependency update tooling after repository automation policy is reviewed.

The repository already contains CodeQL and pull-request dependency review workflows. Security findings should be triaged before release rather than hidden by disabling checks.

## Merge strategy

Prefer squash merge for noisy external contribution branches or merge commits when preserving a carefully structured multi-commit feature history is valuable. Do not rewrite the protected default branch simply to make history look cleaner.
