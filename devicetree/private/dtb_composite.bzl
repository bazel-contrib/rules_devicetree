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

"""Builds a composite dtb by applying overlays on a base dtb."""

load(":base_dtb_info.bzl", "BaseDtbInfo")
load(":utils.bzl", "utils")

visibility("//devicetree/...")

def _dtb_composite_impl(ctx):
    devicetree_toolchain_info = ctx.toolchains["//devicetree:toolchain_type"].devicetree_toolchain_info

    utils.check_tool_exists(devicetree_toolchain_info, "fdtoverlay")

    # If the base dtb comes from a dtb() rule, do an early check that generate_symbols = True.
    # This does not aim to catch all errors; for example, if the dtb() target was wrapped in
    # a filegroup(), BaseDtbInfo is lost, so we can't detect errors until `dtc` is actually
    # executed.
    if BaseDtbInfo in ctx.attr.base:
        if not ctx.attr.base[BaseDtbInfo].generate_symbols:
            fail("{} does not have generate_symbols = True, so overlays can't be applied.".format(
                ctx.attr.base.label,
            ))

    out_name = ctx.attr.out or utils.maybe_add_suffix(ctx.attr.name, ".dtb")
    out = ctx.actions.declare_file(out_name)

    overlays = depset(transitive = [target.files for target in ctx.attr.overlays])

    args = ctx.actions.args()
    args.add("-o", out)
    args.add("-i", ctx.file.base)
    args.add_all(overlays)

    ctx.actions.run(
        executable = devicetree_toolchain_info.fdtoverlay,
        arguments = [args],
        inputs = depset([ctx.file.base], transitive = [overlays]),
        outputs = [out],
        mnemonic = "Fdtoverlay",
        progress_message = "Applying DT overlay %{label}",
    )

    return DefaultInfo(files = depset([out]))

dtb_composite = rule(
    implementation = _dtb_composite_impl,
    doc = "Builds a composite dtb by applying overlays on a base dtb.",
    attrs = {
        "base": attr.label(
            allow_single_file = True,
            doc = """Base `.dtb` to apply overlays on.

                This usually comes from a `dtb()` target with
                `generate_symbols = True`.
            """,
            mandatory = True,
        ),
        "overlays": attr.label_list(
            allow_files = True,
            doc = "List of `.dtbo` overlays to apply.",
        ),
        "out": attr.string(
            doc = """Output file name.

                Default is `name + ".dtb"` if missing extension, otherwise `name`.""",
        ),
    },
    toolchains = [
        "//devicetree:toolchain_type",
    ],
)
