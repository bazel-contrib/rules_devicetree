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

load("@bazel_skylib//lib:paths.bzl", "paths")
load(
    "@rules_cc//cc:find_cc_toolchain.bzl",
    "find_cc_toolchain",
    "use_cc_toolchain",
)
load(":base_dtb_info.bzl", "BaseDtbInfo")
load(":devicetree_library_info.bzl", "DevicetreeLibraryInfo")
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

def _preprocess(
        ctx,
        support_preprocess,
        src,
        # buildifier: disable=unused-variable
        include_files,
        out_attr,
        out_extension,
        deps):
    # Don't preprocess if:
    # - It is disabled in devicetree_toolchain()
    # - For the autodetected devicetree toolchain, no C toolchain is found
    if support_preprocess == False:
        return src

    cc_toolchain = find_cc_toolchain(ctx)
    if support_preprocess == None and not cc_toolchain:
        return src

    if not cc_toolchain:
        fail("DT preprocessing is enabled, but no CC toolchain is found. Please register a CC toolchain.")

    src_extension = paths.split_extension(src.path)[1]  # ".dts" or ".dtso"
    if out_attr:
        out_name = paths.replace_extension(out_attr, ".tmp" + src_extension)
    elif ctx.label.name.endswith("." + out_extension):
        out_name = ctx.label.name.removesuffix("." + out_extension) + ".tmp" + src_extension
    else:
        out_name = ctx.label.name + ".tmp" + src_extension

    out = ctx.actions.declare_file(out_name)

    args = ctx.actions.args()

    # Only run the preprocessor
    args.add("-E")

    # Handle include dirs
    args.add("-nostdinc")
    args.add_all(
        depset(transitive = [target[DevicetreeLibraryInfo].includes for target in deps]),
        before_each = "-I",
        expand_directories = False,
    )

    # Handle defines
    args.add_all(["-undef", "-D__DTS__"])

    # Treat input files as "assembler-with-cpp"
    args.add_all(["-x", "assembler-with-cpp"])

    # Output file
    args.add_all(["-o", out])

    # Input
    args.add(src)

    ctx.actions.run(
        executable = cc_toolchain.preprocessor_executable,
        inputs = depset(
            [src] + include_files,
            transitive = [
                target[DevicetreeLibraryInfo].hdrs
                for target in deps
            ],
        ),
        tools = cc_toolchain.all_files,
        outputs = [out],
        progress_message = "Preprocessing %{label}",
        arguments = [args],
    )

    return out

def _dtc(
        ctx,
        src,
        include_files,
        generate_symbols,
        out_attr,
        out_extension,
        dtcopts,
        devicetree_toolchain_info,
        deps):
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
        deps: list of Targets in deps

    Returns:
        the output file
    """
    out_name = out_attr or utils.maybe_add_suffix(ctx.label.name, "." + out_extension)
    if not out_name.endswith("." + out_extension):
        fail("out does not end with `.{}`".format(out_extension))

    utils.check_tool_exists(devicetree_toolchain_info, "dtc")

    out = ctx.actions.declare_file(out_name)
    args = ctx.actions.args()
    args.add_all(devicetree_toolchain_info.default_dtcopts)
    args.add_all(dtcopts)

    args.add_all(
        depset(transitive = [target[DevicetreeLibraryInfo].includes for target in deps]),
        before_each = "-i",
        expand_directories = False,
    )

    if generate_symbols:
        args.add("-@")
    args.add("-o", out)
    args.add(src)
    ctx.actions.run(
        executable = devicetree_toolchain_info.dtc,
        arguments = [args],
        inputs = depset(
            [src] + include_files,
            transitive = [
                target[DevicetreeLibraryInfo].hdrs
                for target in deps
            ],
        ),
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
        support_preprocess = devicetree_toolchain_info.preprocess,
        src = split_sources.src,
        include_files = split_sources.include_files,
        out_attr = ctx.attr.out,
        out_extension = "dtb",
        deps = ctx.attr.deps,
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
        deps = ctx.attr.deps,
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
            srcs = ["foo.dts"],
        )
        ```
""",
    implementation = _dtb_impl,
    attrs = {
        "srcs": attr.label_list(
            doc = """List of sources.

            There must be exactly one `.dts` file.
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
        "deps": attr.label_list(
            doc = """List of [`devicetree_library()`](devicetree_library.md#devicetree_library) targets for `.dtsi` and `.h inclusion.

                Order matters. See
                [`devicetree_library(includes=)`](devicetree_library.md#devicetree_library-includes)
                for details about ordering of include directories.
            """,
            providers = [DevicetreeLibraryInfo],
        ),
    },
    toolchains = [
        "//devicetree:toolchain_type",
    ] + use_cc_toolchain(mandatory = False),
    fragments = ["cpp"],
)

def _dtbo_impl(ctx):
    devicetree_toolchain_info = ctx.toolchains["//devicetree:toolchain_type"].devicetree_toolchain_info
    split_sources = _split_sources(ctx.files.srcs, "dtso")

    preprocessed = _preprocess(
        ctx = ctx,
        support_preprocess = devicetree_toolchain_info.preprocess,
        src = split_sources.src,
        include_files = split_sources.include_files,
        out_attr = ctx.attr.out,
        out_extension = "dtb",
        deps = ctx.attr.deps,
    )
    out = _dtc(
        ctx = ctx,
        src = preprocessed,
        include_files = split_sources.include_files,
        generate_symbols = False,
        out_attr = ctx.attr.out,
        out_extension = "dtbo",
        dtcopts = ctx.attr.dtcopts,
        devicetree_toolchain_info = devicetree_toolchain_info,
        deps = ctx.attr.deps,
    )
    return [
        DefaultInfo(files = depset([out])),
    ]

dtbo = rule(
    doc = """Build a base devicetree blob overlay (DTBO).

        Example:

        ```starlark
        dtbo(
            name = "baz",
            srcs = ["baz.dtso"],
        )
        ```
""",
    implementation = _dtbo_impl,
    attrs = {
        "srcs": attr.label_list(
            doc = """List of sources.

            There must be exactly one `.dtso` file.
        """,
            allow_files = True,
        ),
        "out": attr.string(
            doc = """Output file name. This should end with `.dtbo`.

                Default is `name + ".dtbo"`, if name does not end with `.dtbo`;
                otherwise `name`.
            """,
        ),
        "dtcopts": attr.string_list(doc = "List of flags to dtc."),
        "deps": attr.label_list(
            doc = """List of [`devicetree_library()`](devicetree_library.md#devicetree_library) targets for `.dtsi` and `.h inclusion.

                Order matters. See
                [`devicetree_library(includes=)`](devicetree_library.md#devicetree_library-includes)
                for details about ordering of include directories.
            """,
            providers = [DevicetreeLibraryInfo],
        ),
    },
    toolchains = [
        "//devicetree:toolchain_type",
    ] + use_cc_toolchain(mandatory = False),
    fragments = ["cpp"],
)
