#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Standalone shell-only prerequisite and cache preservation regressions."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]


class DependencyTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix='hyprlock dependencies with spaces ')
        self.addCleanup(self.temporary.cleanup)
        self.source = Path(self.temporary.name) / 'source tree'
        shutil.copytree(ROOT, self.source, ignore=shutil.ignore_patterns(
            '.git', 'build', '.cache', '__pycache__', 'compile_commands.json'))
        self.env = {k: v for k, v in os.environ.items() if not k.startswith('HOLONIGHT_')}

    def run_workflow(self, command, env=None):
        return subprocess.run([sys.executable, 'tooling/workflow.py', command, '--preset', 'test'],
                              cwd=self.source, env=env or self.env, text=True, capture_output=True)

    def assert_success(self, result):
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_missing_required_tools_fail_before_configure_or_preparation(self):
        tools = Path(self.temporary.name) / 'limited tools'
        tools.mkdir()
        for missing in ('task', 'reuse', 'file'):
            with self.subTest(missing=missing):
                for tool in tools.iterdir():
                    tool.unlink()
                for name in ('c++', 'cmake', 'ninja', 'pkg-config', 'git', 'python3', 'task', 'reuse', 'file'):
                    if name != missing and shutil.which(name):
                        (tools / name).symlink_to(shutil.which(name))
                for command in (('configure', 'build', 'test') if missing == 'file' else
                                ('deps', 'configure', 'build', 'test')):
                    result = self.run_workflow(command, dict(self.env, PATH=str(tools)))
                    self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
                    self.assertIn('missing tools ' + missing, result.stdout + result.stderr)
                    self.assertFalse((self.source / 'build/test/CMakeCache.txt').exists())
                    self.assertFalse((self.source / 'build/deps').exists())
                    self.assertFalse((self.source / 'build/external').exists())

    def test_shell_only_workflows_in_spaces_preserve_stale_configuration(self):
        declaration = json.loads((self.source / 'tooling/module.json').read_text())
        ids = {item['id'] for item in declaration['external_dependencies']}
        self.assertFalse(ids & {'qt', 'gtest'})
        self.assertTrue({'task', 'reuse', 'file', 'compiler'} <= ids)
        self.assertEqual(declaration['dependencies'], [])
        for command in ('configure', 'build', 'test'):
            self.assert_success(self.run_workflow(command))
        self.assertFalse((self.source / 'build/deps').exists())
        self.assertFalse((self.source / 'build/external').exists())
        marker = self.source / 'build/test/previous-marker'
        marker.write_text('preserved')
        presets = self.source / 'CMakePresets.json'
        data = json.loads(presets.read_text())
        data['configurePresets'][1]['cacheVariables']['CMAKE_BUILD_TYPE'] = 'Release'
        presets.write_text(json.dumps(data))
        self.assert_success(self.run_workflow('configure'))
        self.assertEqual((self.source / 'build/test.previous-1/previous-marker').read_text(), 'preserved')
        self.assertFalse(marker.exists())
        self.assert_success(self.run_workflow('deps'))
        self.assertFalse((self.source / 'build/deps/prefix').exists())
        self.assertFalse((self.source / 'build/external').exists())


if __name__ == '__main__':
    unittest.main()
