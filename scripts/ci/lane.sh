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
python3 scripts/ci/test_launcher.py
sh -n scripts/status scripts/run-nested-test.sh tests/test-status.sh tests/test-package.sh
cmake -S . -B build/verification -G Ninja -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_TESTING=ON
cmake --build build/verification --parallel 2
ctest --test-dir build/verification --output-on-failure --no-tests=error
