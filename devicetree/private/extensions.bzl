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
load(":constants.bzl", "TOOLCHAIN_TOOLS")
load(":devicetree_toolchains_repo.bzl", "devicetree_toolchains_repo")
load(":hermetic_toolchain_repo.bzl", "devicetree_hermetic_toolchain_repo")

visibility("private")

def _toolchains_impl(module_ctx):
    hermetic_tags = [
        tag
        for module in module_ctx.modules
        for tag in module.tags.hermetic
    ]
    if len(hermetic_tags) != 1:
        fail("The `toolchains` extension requires exactly one `hermetic(...)` tag but found {}.".format(
            len(hermetic_tags),
        ))

    hermetic_kwargs = {
        tool_name: getattr(hermetic_tags[0], tool_name)
        for tool_name in TOOLCHAIN_TOOLS
    }

    devicetree_autodetected_toolchain_repo(name = "devicetree_local_toolchain")
    devicetree_hermetic_toolchain_repo(name = "devicetree_hermetic_toolchain", **hermetic_kwargs)
    devicetree_toolchains_repo(name = "devicetree_toolchains")
    return module_ctx.extension_metadata(reproducible = True)

_hermetic_tag = tag_class(
    doc = """\
Configures the hermetic devicetree toolchain.

Provide labels to the tool binaries (typically the targets exported by the
[`dtc` BCR module](https://registry.bazel.build/modules/dtc)) that the
default-registered toolchain should invoke.
""",
    attrs = {
        tool_name: attr.label(mandatory = True, doc = doc)
        for tool_name, doc in TOOLCHAIN_TOOLS.items()
    },
)

toolchains = module_extension(
    implementation = _toolchains_impl,
    tag_classes = {"hermetic": _hermetic_tag},
    doc = """\
Creates the devicetree toolchain repositories.

This extension is used internally by `rules_devicetree` to register the
default toolchain. It does not need to be invoked by downstream modules.
""",
)
