# Local CI rehearsal

Baseline: 2af2a7b843f2608639861446e88b2831cd4bae1d. Umbrella package CI-009.

Add missing hosted automated build/package verification, using the same script
as task ci. Configure a fresh Debug/Ninja tree with BUILD_TESTING=ON, build all
targets and run both status-helper and package-layout CTest checks with failure
output and no-tests=error. Run shell syntax validation of helper and test scripts.
Retain the existing licensing job and push/PR triggers with immutable REUSE 6.2.0.
Use the accepted immutable compiler/CMake image. No new production dependencies.

Snapshot tracked edits and non-ignored new files; preserve modes/symlinks and
omit deleted/ignored inputs. Report untracked inputs to add before pushing.
Mount input read-only, use disposable writable trees and retain host-owned complete
logs, source state, tool versions, image identities and lane results in build/ci.
Docker first; Podman fallback preserves rootless mapping. Missing/failed checks
return nonzero. Do not install to the host, push, or change umbrella pins.

Keep task test and task test:nested unchanged for separate manual visual acceptance.
CI exercises private fake status backends and disposable DESTDIR packaging; it
requires no host compositor, pointer/focus automation, audio service or installation.
The asset-only CMake project explicitly defaults its install libdir to lib,
matching existing presets, so GNUInstallDirs does not infer an absent architecture.
There are no application compilation targets or compile commands to generate.

2026-10-03 acceptance: task ci passes both lanes with fresh snapshots, logged at
build/ci/20261003T142050Z-ckjhnerw/. Both status/package CTest checks pass, as do
shell syntax and four launcher regressions. A host configure and the same two
CTest checks pass. Source/development-build isolation passes for 38 files;
complete logs were reviewed without warnings. Native documentation REUSE lint
and final diff checks pass. Existing nested visual tasks are preserved and were
not run because this change has no visual behavior and CI needs no host desktop.
Real Podman is unavailable locally; its mapping is tested with a fake runtime.
