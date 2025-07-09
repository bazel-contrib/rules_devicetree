# Copyright (C) 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import argparse
import logging
import unittest
import pathlib
import sys

arguments: argparse.Namespace


def load_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument("bzl_files", nargs="*", type=pathlib.Path)
    args, unknown = parser.parse_known_args()
    return args, unknown


class BzlLoadVisibilityTest(unittest.TestCase):
    def test_bzl_files_have_load_visibility(self):
        for bzl_file in arguments.bzl_files:
            with self.subTest(bzl_file=bzl_file):
                with bzl_file.open() as f:
                    has_visibility = any([line.startswith("visibility(")
                                          for line in f.readlines()])
                    self.assertTrue(has_visibility,
                                    f"File {bzl_file} does not have visibility")


if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO, format="%(levelname)s: %(message)s"
    )
    arguments, unknown = load_arguments()
    sys.argv[1:] = unknown
    unittest.main()
