# Copyright (C) 2026 Google LLC
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

"""Module extensions for `rules_devicetree`."""

load(":autodetected_toolchain_repo.bzl", "devicetree_autodetected_toolchain_repo")
load(":devicetree_toolchains_repo.bzl", "devicetree_toolchains_repo")

visibility("private")

def _toolchains_impl(module_ctx):
    devicetree_autodetected_toolchain_repo(name = "devicetree_local_toolchain")
    devicetree_toolchains_repo(name = "devicetree_toolchains")
    return module_ctx.extension_metadata(reproducible = True)

toolchains = module_extension(
    implementation = _toolchains_impl,
    doc = """\
Creates the devicetree toolchain repositories.

This extension is used internally by `rules_devicetree` to register the
default toolchain. It does not need to be invoked by downstream modules.
""",
)
