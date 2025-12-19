"""This module implements the language-specific toolchain rule.
"""

load("//devicetree/private:constants.bzl", "TOOLCHAIN_TOOLS")
load("//devicetree/private:devicetree_toolchain_info.bzl", "DevicetreeToolchainInfo")

# This is public so that autodetected_toolchain_repo can use autodetected_devicetree_toolchain.
# It shouldn't be load()ed directly by users of @rules_devicetree.
visibility("public")

# Avoid using non-normalized paths (workspace/../other_workspace/path)
def _to_manifest_path(ctx, file):
    if file.short_path.startswith("../"):
        return "external/" + file.short_path[3:]
    else:
        return ctx.workspace_name + "/" + file.short_path

def _devicetree_toolchain_impl(ctx):
    transitive_tool_files = []
    transitive_tool_runfiles = []
    template_variables = {}
    devicetree_toolchain_info_fields = {}

    for tool_name in TOOLCHAIN_TOOLS:
        target = getattr(ctx.attr, tool_name)
        if not target:
            continue
        transitive_tool_files.append(target.files)
        transitive_tool_runfiles.append(target[DefaultInfo].default_runfiles)
        tool_path = _to_manifest_path(ctx, target.files.to_list()[0])
        template_variables[tool_name.upper()] = tool_path
        devicetree_toolchain_info_fields[tool_name] = getattr(ctx.executable, tool_name)

    tool_files = depset(transitive = transitive_tool_files)

    runfiles = ctx.runfiles(transitive_files = tool_files)
    runfiles = runfiles.merge_all(transitive_tool_runfiles)

    # Make variables available in places like genrules.
    # See https://docs.bazel.build/versions/main/be/make-variables.html#custom_variables
    template_variables = platform_common.TemplateVariableInfo(template_variables)

    default = DefaultInfo(
        files = tool_files,
        runfiles = runfiles,
    )
    devicetree_toolchain_info = DevicetreeToolchainInfo(
        label = ctx.label,
        default_dtcopts = ctx.attr.default_dtcopts,
        preprocess = getattr(ctx.attr, "preprocess", None),
        **devicetree_toolchain_info_fields
    )

    # Export all the providers inside our ToolchainInfo
    # so the resolved_toolchain rule can grab and re-export them.
    toolchain_info = platform_common.ToolchainInfo(
        devicetree_toolchain_info = devicetree_toolchain_info,
        template_variables = template_variables,
        default = default,
    )
    return [
        default,
        toolchain_info,
        template_variables,
    ]

_common_attrs = {
    name: attr.label(
        doc = doc,
        mandatory = False,
        allow_single_file = True,
        cfg = "exec",
        executable = True,
    )
    for name, doc in TOOLCHAIN_TOOLS.items()
} | {
    "default_dtcopts": attr.string_list(doc = "Default list of flags to dtc"),
}

devicetree_toolchain = rule(
    implementation = _devicetree_toolchain_impl,
    attrs = _common_attrs | {
        "preprocess": attr.bool(
            mandatory = True,
            doc = """Whether source files are preprocessed.

            If true, allow preprocessing directives in source files (`*.dts`, `*.dtso`).
            The CC toolchain must be available.

            If false, preprocessing directives are not allowed.
""",
        ),
    },
    doc = """Defines a devicetree toolchain.

For usage see https://docs.bazel.build/versions/main/toolchains.html#defining-toolchains.
""",
)

autodetected_devicetree_toolchain = rule(
    implementation = _devicetree_toolchain_impl,
    # This intentionally does not have `preprocess` so that DevicetreeInfo.preprocess = None.
    attrs = _common_attrs,
)
