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

"""Builds device tree blobs."""

load(":base_dtb_info.bzl", "BaseDtbInfo")
load(":utils.bzl", "utils")

visibility("//devicetree/...")

def _split_sources(srcs, src_extension):
    """Split the list of `srcs`.

    Args:
        srcs: ctx.attr.srcs
        src_extension: expected extension of the source file

    Returns:
        struct of these fields:

        *   src: the single source file
        *   include_files: other include files
    """
    sources = []
    include_files = []
    for file in srcs:
        if not file.extension == src_extension:
            include_files.append(file)
        else:
            sources.append(file)

    if len(sources) != 1:
        fail("Expect exactly one .{} file in srcs, got {}".format(src_extension, sources))

    return struct(
        src = sources[0],
        include_files = include_files,
    )

# buildifier: disable=unused-variable
def _preprocess(ctx, src, include_files):
    # TODO(#7): Support preprocess directives
    return src

def _dtc(
        ctx,
        src,
        include_files,
        generate_symbols,
        out_attr,
        out_extension,
        dtcopts,
        devicetree_toolchain_info):
    """Invokes dtc.

    Args:
        ctx: ctx
        src: The single source file
        include_files: extra inputs to the action
        generate_symbols: whether to generate symbols
        out_attr: the `out` attribute of the rule
        out_extension: extension of output file without the dot
        dtcopts: list of flags to dtc
        devicetree_toolchain_info: `DevicetreeToolchainInfo` of resolved toolchain

    Returns:
        the output file
    """
    out_name = out_attr or utils.maybe_add_suffix(ctx.label.name, "." + out_extension)
    if not out_name.endswith("." + out_extension):
        fail("out does not end with `.{}`".format(out_extension))

    out = ctx.actions.declare_file(out_name)
    args = ctx.actions.args()
    args.add_all(devicetree_toolchain_info.default_dtcopts)
    args.add_all(dtcopts)

    if generate_symbols:
        args.add("-@")
    args.add("-o", out)
    args.add(src)
    ctx.actions.run(
        executable = devicetree_toolchain_info.dtc,
        arguments = [args],
        inputs = [src] + include_files,
        outputs = [out],
        mnemonic = "Dtc",
        progress_message = "Building {} %{{label}}".format(out_extension.upper()),
    )
    return out

def _dtb_impl(ctx):
    devicetree_toolchain_info = ctx.toolchains["//devicetree:toolchain_type"].devicetree_toolchain_info
    split_sources = _split_sources(ctx.files.srcs, "dts")

    preprocessed = _preprocess(
        ctx = ctx,
        src = split_sources.src,
        include_files = split_sources.include_files,
    )
    out = _dtc(
        ctx = ctx,
        src = preprocessed,
        include_files = split_sources.include_files,
        generate_symbols = ctx.attr.generate_symbols,
        out_attr = ctx.attr.out,
        out_extension = "dtb",
        dtcopts = ctx.attr.dtcopts,
        devicetree_toolchain_info = devicetree_toolchain_info,
    )
    return [
        DefaultInfo(files = depset([out])),
        BaseDtbInfo(
            generate_symbols = ctx.attr.generate_symbols,
        ),
    ]

dtb = rule(
    doc = """Build a base devicetree blob (DTB).

        Example:

        ```starlark
        dtb(
            name = "foo",
            srcs = [
                "foo.dts",
                "bar.dtsi",
            ],
        )
        ```
""",
    implementation = _dtb_impl,
    attrs = {
        "srcs": attr.label_list(
            doc = """List of sources.

            There must be exactly one `.dts` file. Beside the `.dts` file,
            extra include files like `.dtsi` can be specified.
        """,
            allow_files = True,
        ),
        "generate_symbols": attr.bool(doc = """Enable generation of symbols (-@).

            This is necessary if you are applying overlays on top of it.
        """),
        "out": attr.string(
            doc = """Output file name. This should end with `.dtb`.

                Default is `name + ".dtb"`, if name does not end with `.dtb`;
                otherwise `name`.
            """,
        ),
        "dtcopts": attr.string_list(doc = "List of flags to dtc."),
    },
    toolchains = [
        "//devicetree:toolchain_type",
    ],
)
