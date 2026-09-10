"""Analysis tests for the template variables of `devicetree_toolchain()`."""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

def _template_variables_test_impl(ctx):
    env = analysistest.begin(ctx)

    variables = analysistest.target_under_test(env)[platform_common.TemplateVariableInfo].variables

    for tool, short_path in ctx.attr.expected_short_paths.items():
        rlocationpath = "{}/{}".format(ctx.workspace_name, short_path)

        asserts.equals(env, short_path, variables[tool + "_EXECPATH"], tool + "_EXECPATH")
        asserts.equals(env, short_path, variables[tool + "_ROOTPATH"], tool + "_ROOTPATH")
        asserts.equals(env, rlocationpath, variables[tool + "_RLOCATIONPATH"], tool + "_RLOCATIONPATH")

        # For a source file of the main repository, the legacy `$({TOOL})`
        # variable happens to match `$({TOOL}_RLOCATIONPATH)`.
        asserts.equals(env, rlocationpath, variables[tool], tool)

    for tool in ctx.attr.external_tools:
        execpath = variables[tool + "_EXECPATH"]
        rootpath = variables[tool + "_ROOTPATH"]
        rlocationpath = variables[tool + "_RLOCATIONPATH"]

        # The canonical repository name of an external repository is not
        # stable across Bazel versions, so assert the shape of the paths
        # instead of their exact values.
        asserts.equals(env, "../" + rlocationpath, rootpath, tool + "_ROOTPATH")
        asserts.true(
            env,
            execpath.endswith("/" + rlocationpath),
            "{}_EXECPATH ({}) should end with {}".format(tool, execpath, rlocationpath),
        )

        # The legacy `$({TOOL})` variable stays on the
        # `--legacy_external_runfiles` layout, which this repository disables
        # and which Bazel 8 no longer enables by default.
        asserts.equals(env, "external/" + rlocationpath, variables[tool], tool)

    return analysistest.end(env)

template_variables_test = analysistest.make(
    impl = _template_variables_test_impl,
    attrs = {
        "expected_short_paths": attr.string_dict(
            doc = "Template variable prefix (e.g. `DTC`) to workspace relative path of the tool.",
        ),
        "external_tools": attr.string_list(
            doc = "Template variable prefixes (e.g. `DTC`) of tools that come from an external repository.",
        ),
    },
)
