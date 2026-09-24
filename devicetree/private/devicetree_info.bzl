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

"""Headers and include directories of a devicetree target."""

visibility("//devicetree/...")

DevicetreeInfo = provider(
    doc = """Headers and include directories of a devicetree target.

        Any rule may return this provider to make its generated `.dtsi` and
        `.h` files usable from the `deps` of
        [`dtb()`](../dtb.bzl/dtb) and [`dtbo()`](../dtbo.bzl/dtbo); it is not limited
        to [`devicetree_library()`](../devicetree_library.bzl/devicetree_library).

        Both depsets must be constructed with `order = "postorder"` so that
        include directories from dependencies precede those of the target
        itself. See
        [`devicetree_library(includes=)`](../devicetree_library.bzl/devicetree_library).
    """,
    fields = {
        "hdrs": """(`depset` of `File`) Header files (`.h`, `.dtsi`) made
            available to dependents, including those of dependencies. These
            become inputs of the preprocessor and `dtc` actions.
        """,
        "includes": """(`depset` of `File`) Directories added to the
            preprocessor (`-I`) and `dtc` (`-i`) search path, including those
            of dependencies. These are `File`s of directories, not of files.
        """,
    },
)
