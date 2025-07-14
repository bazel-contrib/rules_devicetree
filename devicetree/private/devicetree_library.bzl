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

"""A library of `.dtsi` and `.h` files that can be used in [`dtb()`](dtb.md#dtb)
and [`dtbo()`](dtbo.md#dtbo)."""

load(":devicetree_library_info.bzl", "DevicetreeLibraryInfo")

visibility("//devicetree/...")

def _devicetree_library_impl(ctx):
    # Use postorder traversal: deps first, then my elements.
    # Note: even though we don't have direct elements in these depsets,
    #   still specify order = "postorder" to state the intent.
    hdrs = depset(
        transitive = [dep[DevicetreeLibraryInfo].hdrs for dep in ctx.attr.deps] +
                     [target.files for target in ctx.attr.hdrs],
        order = "postorder",
    )
    includes = depset(
        transitive = [dep[DevicetreeLibraryInfo].includes for dep in ctx.attr.deps] +
                     [target.files for target in ctx.attr.includes],
        order = "postorder",
    )

    devicetree_library_info = DevicetreeLibraryInfo(
        hdrs = hdrs,
        includes = includes,
    )
    return devicetree_library_info

devicetree_library = rule(
    implementation = _devicetree_library_impl,
    doc = """A library of `.dtsi` and `.h` files that can be used in
        [`dtb()`](dtb.md#dtb) and [`dtbo()`](dtbo.md#dtbo).""",
    attrs = {
        "hdrs": attr.label_list(
            allow_files = True,
            doc = """List of exported included files (`.h`, `.dtsi`).

                These files are visible to all targets that transitively depend
                on this target.""",
        ),
        "includes": attr.label_list(
            allow_files = True,
            doc = """List of exported include directories in the current package.

                These `-i` are added to all [`dtb()`](dtb.md#dtb) and
                [`dtbo()`](dtbo.md#dtbo) targets that transitively depend on
                this target.

                These should be labels to **directories**, not files. For
                example:

                ```starlark
                devicetree_library(
                    name = "mylib",
                    hdrs = ["include/myfile.dtsi"],
                    includes = ["include"],
                )
                ```

                **Ordering**

                Include directories are collected with `postorder` traversal;
                that is, `includes` from dependencies are added
                first, then `includes` from this target are added.
            """,
        ),
        "deps": attr.label_list(
            doc = "Transitive `devicetree_library()` targets.",
            providers = [DevicetreeLibraryInfo],
        ),
    },
)
