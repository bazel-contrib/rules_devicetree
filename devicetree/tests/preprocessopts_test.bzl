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

"""Analysis tests for `default_preprocessopts` and `preprocessopts`."""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

_TOOLCHAIN = "//devicetree/tests:preprocessopts_toolchain"
_NO_PREPROCESS_TOOLCHAIN = "//devicetree/tests:no_preprocess_toolchain"

def _preprocess_action(env):
    """Returns the action that runs the C preprocessor on the source file.

    Args:
        env: The analysistest environment.

    Returns:
        The `Action`, or `None` if the target has no preprocessing action.
    """
    for action in analysistest.target_actions(env):
        if action.mnemonic == "DtPreprocess":
            return action
    return None

def _preprocessopts_test_impl(ctx):
    env = analysistest.begin(ctx)

    action = _preprocess_action(env)
    asserts.true(env, action != None, "no preprocessing action was registered")
    if action == None:
        return analysistest.end(env)

    argv = action.argv

    # Assert that the expected flags appear, in the expected relative order.
    # Other flags may be interleaved.
    previous_flag = None
    previous_index = -1
    for flag in ctx.attr.expected_flag_order:
        asserts.true(env, flag in argv, "{} is missing from {}".format(flag, argv))
        if flag not in argv:
            return analysistest.end(env)

        index = argv.index(flag)
        asserts.true(
            env,
            previous_index < index,
            "{} should come before {}, got {}".format(previous_flag, flag, argv),
        )
        previous_flag = flag
        previous_index = index

    for flag in ctx.attr.unexpected_flags:
        asserts.false(env, flag in argv, "{} should not be in {}".format(flag, argv))

    return analysistest.end(env)

preprocessopts_test = analysistest.make(
    impl = _preprocessopts_test_impl,
    attrs = {
        "expected_flag_order": attr.string_list(
            doc = "Flags that must appear in the preprocessor command line, in this order.",
        ),
        "unexpected_flags": attr.string_list(
            doc = "Flags that must not appear in the preprocessor command line.",
        ),
    },
    config_settings = {
        # Take precedence over the toolchain the hub repository registers, so
        # the target under test resolves to a toolchain with `default_preprocessopts`.
        "//command_line_option:extra_toolchains": [_TOOLCHAIN],
    },
)

def _preprocessopts_error_test_impl(ctx):
    env = analysistest.begin(ctx)
    asserts.expect_failure(env, ctx.attr.error_message)
    return analysistest.end(env)

preprocessopts_error_test = analysistest.make(
    impl = _preprocessopts_error_test_impl,
    expect_failure = True,
    attrs = {
        "error_message": attr.string(
            doc = "Substring the analysis failure is expected to contain.",
        ),
    },
    config_settings = {
        "//command_line_option:extra_toolchains": [_NO_PREPROCESS_TOOLCHAIN],
    },
)
