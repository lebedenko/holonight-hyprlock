# External dependency management — holonight-hyprlock

Work package: EDM-021
Baseline: `def9618fca833535275e8a8aa9a0e577acda8377`
Umbrella audit: `38146d8f474317f3f8d72699f60e6d16a71dd165`
Status: Implemented and verified locally; publication and integration pending. Implementation baseline: `a366a31eaf1b6836a84882a47fe74c34469f7be0`.
Canonical preparation checkpoint: `33d1c95` (bundle 2.0.0).

## Requirements

- Configuration and normal build commands shall never acquire dependencies or prepare source providers.
- `task deps` shall check installed build/tool prerequisites; this shell-only module has no providers.
  Test workflows additionally validate the package-test `file` prerequisite.
- Internal providers shall resolve only from approved prefixes; external packages shall resolve from an explicit
  external prefix or normal system locations.
- Enabled dependency-dependent features shall require their dependencies; minimal profiles shall disable them explicitly.
- Where production components use Qt, discovery shall require >=6.11; private Qt components shall match
  the selected public version exactly.
- Where tests use GTest, consumers shall require installed GTest >=1.14 CONFIG and any GMock targets they use.
- Existing public APIs, component switches, install-tree consumers and acceptance coverage shall be preserved.

## Design

Adopt canonical `tooling/modules/holonight-hyprlock.json` and `.cmake`, then synchronize bundle 2.0.0 into this repository.
The copied metadata is owned by this standalone checkout. CMake performs authoritative discovery; shared probes
provide prerequisite diagnostics and record resolved versions/paths. Incompatible caches and local provider install
trees are archived before reuse. Package acquisition occurs only in explicit environment preparation. CI switches
build/runtime/release lanes together to qualified immutable images and runs acceptance offline after preparation.

Preserve the shell-only production profile, optional wpctl behavior, packaging tests and manual nested compositor acceptance.

## Implementation and verification tasks

- [x] Confirm the exact baseline and canonical handoff before implementation.
- [x] Adopt declarations, prefix helpers, explicit preparation and compatibility signatures.
- [x] Apply the repository-specific discovery changes above.
- [x] Update Task, CI preparation/entrypoints, Dockerfiles, release lanes and contributor instructions.
- [x] Run declaration/CMake/profile consistency checks and offline missing-package regressions.
- [x] Run narrow regressions, clean acceptance, installed-package consumers and required quality checks.
- [x] Inspect complete logs; record commands, versions, features, warnings and manual checks.
- [x] Make a repository-local commit only after local verification; publish only when authorized.

## EDM-021 implementation

- Corrected canonical declaration adopted: retain compiler/CMake/Ninja/pkgconf/Git/Python;
  add Task/REUSE tools and test-scoped file; remove unused Qt/GTest.
- Synchronize bundle 2.0.0 only into this standalone checkout. Preserve production
  LANGUAGES NONE, install paths, optional wpctl, status helper and nested preview.
- Retain build-test/licensing lanes. Build uses qualified full image
  `ghcr.io/lebedenko/holonight-deps@sha256:37ca051c39d1688d6413c47d94b8c0f221152dac6981ec67d155f2c43ea17b40`;
  REUSE digest is unchanged. Explicit acquisition/inspection precedes offline execution.
- Record SHA-256 inputs, pull logs, image inspection, full package/tool versions and lane logs.
- Exercise Task workflows, both CTest registrations, shell syntax and explicit
  Release/tests-OFF staged package assertions in disposable rootless containers.
- Add launcher acquisition/offline regressions and dependency diagnostics, space-path,
  no-preparation and stale-cache preservation regressions.

## Verification — 2026-10-15

Complete logs and source manifests are retained by the coordinator in
`docs/initiatives/external-dependency-management/verification/edm021/`.
The local raw artifacts remain in ignored `build/ci/`.

- Host: `python3 scripts/ci/test_launcher.py`: 5/5; acquisition failure, missing runtime,
  offline flags, read-only snapshots, user mapping and both failed-lane propagation.
- Host and qualified Arch build-test: `python3 scripts/ci/test_dependencies.py`: 2/2;
  missing Task/REUSE diagnostics for deps/configure/build/test, missing file diagnostics
  for test configure/build/test, source paths containing spaces, workflows without
  provider preparation and stale configuration archival. `task deps` checks tool/build
  scope; file is test-only and is checked by test configuration.
- `python3 scripts/ci/run.py`: clean build-test and licensing both exit 0
  (`20261015T074801Z-7gh7nnmr`). Both images explicitly pulled and inspected;
  linux/amd64 acceptance ran as UID/GID 1000:1000 with read-only input,
  `--pull=never --network=none`, disposable source/build and private DESTDIR.
- Final review corrected the syntax command to check each shell script individually
  and retained previously suppressed package configure/install output. Reran only
  the affected build-test lane: exit 0 (`20261015T074846Z-uifnf6lc`).
- Build-test executes `task deps PRESET=test`, `task configure PRESET=test`,
  `task build PRESET=test`, `task test:auto PRESET=test`: Debug status-helper and
  package-layout both pass (2/2). Existing status tests cover missing/malformed wpctl,
  battery handling and escaped user names.
- `task configure PRESET=release`, `task build PRESET=release`, and
  `sh tests/test-package.sh cmake "$PWD" Release`: Release/tests-OFF staging passes,
  including fallback configuration paths, PNG assets and executable helper.
- REUSE 6.2.0: 41/41 files compliant with REUSE specification 3.3. Licensing remains
  valid after the logging-only correction; final documentation is checked separately.
- Canonical: `python3 -m unittest discover -s tooling -p 'test_*.py'`: 32/32;
  declaration validation, generated-profile `--check`, and bundle `sync.py --check
  --module holonight-hyprlock` pass. Standalone module/dependencies match canonical.
- Tool versions: Python 3.14.7, Git 2.55.0, CMake 4.4.3, Ninja 1.13.2,
  file 5.48, Task 3.53.1, REUSE 6.2.0, GCC 16.2.1, pkgconf 3.0.7,
  hyprlock 0.9.6-3. Full package versions are in build-test.log.
- Complete logs reviewed: no actionable warnings. Zero compile commands and Ninja
  reporting no work are expected for LANGUAGES NONE. Launcher fixture FAIL/error
  messages are intentional negative tests; both actual acceptance lanes passed.

Publication/pinning, Debian support, new image qualification, host installation and nested visual acceptance
are outside EDM-021. Manual nested acceptance remains pending for EDM-022.
