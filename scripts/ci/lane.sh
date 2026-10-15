#!/bin/sh
set -eu
lane=$1
mkdir /work/source
cp -a /input/. /work/source/
cd /work/source
export HOME=/work/build/home LC_ALL=C.UTF-8 TZ=UTC
mkdir -p "$HOME"
if [ "$lane" = licensing ]; then
  reuse --version
  reuse lint
  exit
fi
[ "$lane" = build-test ] || exit 2
python3 --version
git --version
cmake --version
ninja --version
file --version
task --version
reuse --version
c++ --version
pkg-config --version
pacman --config /dev/null -Q
python3 scripts/ci/test_launcher.py
python3 scripts/ci/test_dependencies.py
for script in scripts/status scripts/run-nested-test.sh scripts/ci/lane.sh tests/test-status.sh tests/test-package.sh; do
  sh -n "$script"
done
task deps PRESET=test
task configure PRESET=test
task build PRESET=test
task test:auto PRESET=test
cat build/test/Testing/Temporary/LastTest.log
task configure PRESET=release
task build PRESET=release
# Explicit Release/tests-OFF staging uses the same package assertions as CTest.
sh tests/test-package.sh cmake "$PWD" Release
