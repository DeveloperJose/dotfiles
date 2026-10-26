import importlib.util
from pathlib import Path
import os
import stat
import subprocess
import tempfile
import unittest
from unittest.mock import patch


def load_module(name):
    path = Path(__file__).resolve().parents[1] / "scripts" / (name + ".py")
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


home_module = load_module("activate-home")
system_module = load_module("apply-system")


class HomeMigrationTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        root = Path(self.temporary.name)
        self.home = root / "home"
        self.repo = self.home / "dotfiles"
        self.source = self.repo / "shared/.config/fish"
        self.source.mkdir(parents=True)
        (self.source / "fish_variables").write_text("local state")
        self.target = self.home / ".config/fish"
        self.target.parent.mkdir()
        self.target.symlink_to("../dotfiles/shared/.config/fish")
        self.generation = root / "generation"
        files = self.generation / "home-files/.config"
        files.mkdir(parents=True)
        (files / "fish").symlink_to(self.source)

    def test_transfers_directory_link_without_touching_state(self):
        def activate(*args, **kwargs):
            self.assertFalse(self.target.is_symlink())
            self.target.symlink_to("/nix/store/example-home-manager-files/.config/fish")

        with patch.object(home_module.subprocess, "run", side_effect=activate):
            home_module.activate(self.generation, self.repo, self.home)
        self.assertEqual((self.source / "fish_variables").read_text(), "local state")
        saved = list((self.home / ".dotfiles_backups").glob("*/.config/fish"))
        self.assertEqual(len(saved), 1)
        self.assertEqual(os.readlink(saved[0]), "../dotfiles/shared/.config/fish")

    def test_failed_partial_activation_restores_original_link(self):
        def activate(*args, **kwargs):
            self.target.symlink_to("/nix/store/failed-home-manager-files/.config/fish")
            raise subprocess.CalledProcessError(1, "activate")

        with patch.object(home_module.subprocess, "run", side_effect=activate):
            with self.assertRaises(subprocess.CalledProcessError):
                home_module.activate(self.generation, self.repo, self.home)
        self.assertEqual(os.readlink(self.target), "../dotfiles/shared/.config/fish")
        self.assertEqual((self.target / "fish_variables").read_text(), "local state")

    def test_leaves_foreign_links_for_home_manager_collision_checks(self):
        foreign = self.home / "unrelated"
        foreign.mkdir()
        replacement = self.target.parent / "replacement"
        replacement.symlink_to(foreign)
        os.replace(replacement, self.target)
        with patch.object(home_module.subprocess, "run"):
            home_module.activate(self.generation, self.repo, self.home)
        self.assertEqual(os.readlink(self.target), str(foreign))
        self.assertFalse((self.home / ".dotfiles_backups").exists())


class SystemMigrationTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        root = Path(self.temporary.name)
        self.source = root / "bundle"
        self.destination = root / "destination"
        self.backup = root / "backup"
        self.source.mkdir()
        self.destination.mkdir()

    def test_replaces_link_preserving_original_source_and_backup(self):
        live_source = self.source.parent / "live-config"
        live_source.write_text("original")
        target = self.destination / "config"
        target.symlink_to(live_source)
        (self.source / "config").write_text("managed")
        (self.source / "config").chmod(0o444)
        count = system_module.install_files(self.source, self.destination, self.backup)
        self.assertEqual(count, 1)
        self.assertFalse(target.is_symlink())
        self.assertEqual(target.read_text(), "managed")
        self.assertEqual(live_source.read_text(), "original")
        self.assertEqual((self.backup / "files/config").read_text(), "original")
        self.assertEqual(os.readlink(self.backup / "links/config"), str(live_source))
        self.assertEqual(stat.S_IMODE(target.stat().st_mode), 0o644)

    def test_preserves_executability_and_skips_unchanged_files(self):
        program = self.source / "program"
        program.write_text("#!/bin/sh\nexit 0\n")
        program.chmod(0o555)
        self.assertEqual(system_module.install_files(self.source, self.destination, self.backup), 1)
        self.assertEqual(stat.S_IMODE((self.destination / "program").stat().st_mode), 0o755)
        self.assertEqual(system_module.install_files(self.source, self.destination, self.backup), 0)

    def test_rejects_symlink_parents_before_installing_any_file(self):
        (self.source / "a-first").write_text("new")
        (self.source / "z-directory").mkdir()
        (self.source / "z-directory/config").write_text("managed")
        live_directory = self.source.parent / "live-directory"
        live_directory.mkdir()
        (live_directory / "config").write_text("original")
        (self.destination / "z-directory").symlink_to(live_directory)
        with self.assertRaisesRegex(ValueError, "directory symlink"):
            system_module.install_files(self.source, self.destination, self.backup)
        self.assertFalse((self.destination / "a-first").exists())
        self.assertEqual((live_directory / "config").read_text(), "original")

    def test_requires_root_before_loading_bundle(self):
        with patch.object(system_module.os, "geteuid", return_value=1000):
            with self.assertRaisesRegex(SystemExit, "sudo"):
                system_module.main()


if __name__ == "__main__":
    unittest.main()
