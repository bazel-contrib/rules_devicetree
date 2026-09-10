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

    return analysistest.end(env)

template_variables_test = analysistest.make(
    impl = _template_variables_test_impl,
    attrs = {
        "expected_short_paths": attr.string_dict(
            doc = "Template variable prefix (e.g. `DTC`) to workspace relative path of the tool.",
            mandatory = True,
        ),
    },
)
