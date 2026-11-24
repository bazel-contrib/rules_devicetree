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

"""Analysis tests for `dtb()` with a `.dtb` source."""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("//devicetree/private:base_dtb_info.bzl", "BaseDtbInfo")

_TOOLCHAIN = "//devicetree/tests:dtcopts_toolchain"
_PREPROCESSING_TOOLCHAIN = "//devicetree/tests:preprocessopts_toolchain"

def _actions(env, mnemonic):
    return [
        action
        for action in analysistest.target_actions(env)
        if action.mnemonic == mnemonic
    ]

def _assert_not_preprocessed(env):
    """Asserts that only `dtc` runs on the source.

    Args:
        env: The analysistest environment.

    Returns:
        The single `Dtc` action, or `None` on failure.
    """
    asserts.equals(env, 0, len(_actions(env, "DtPreprocess")), "a .dtb source must not be preprocessed")
    dtc_actions = _actions(env, "Dtc")
    asserts.equals(env, 1, len(dtc_actions), "expected a single dtc action")
    return dtc_actions[0] if len(dtc_actions) == 1 else None

def _dtb_from_dtb_test_impl(ctx):
    env = analysistest.begin(ctx)

    dtc_action = _assert_not_preprocessed(env)
    if not dtc_action:
        return analysistest.end(env)

    # The source `.dtb` is read directly.
    inputs = dtc_action.inputs.to_list()
    asserts.true(
        env,
        any([f.extension == "dtb" for f in inputs]),
        "dtc must read the .dtb source, got inputs {}".format(inputs),
    )

    # Assert that the expected flags appear, in the expected relative order.
    # Other flags may be interleaved.
    argv = dtc_action.argv
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

    # `-I dtb` must be the last `-I`, so a default `-I dts` cannot win.
    last_i = -1
    for index in range(len(argv)):
        if argv[index] == "-I":
            last_i = index
    asserts.true(env, last_i >= 0 and last_i + 1 < len(argv), "-I is missing from {}".format(argv))
    if last_i >= 0 and last_i + 1 < len(argv):
        asserts.equals(env, "dtb", argv[last_i + 1], "the last -I must be dtb, got {}".format(argv))

    target = analysistest.target_under_test(env)
    asserts.equals(
        env,
        ctx.attr.expect_base_dtb_info,
        BaseDtbInfo in target,
        "unexpected BaseDtbInfo presence on {}".format(target.label),
    )
    if ctx.attr.expect_base_dtb_info and BaseDtbInfo in target:
        asserts.equals(
            env,
            ctx.attr.expected_generate_symbols,
            target[BaseDtbInfo].generate_symbols,
            "BaseDtbInfo.generate_symbols must be forwarded from the source",
        )

    return analysistest.end(env)

_ATTRS = {
    "expect_base_dtb_info": attr.bool(
        doc = "Whether the target is expected to carry `BaseDtbInfo`.",
    ),
    "expected_flag_order": attr.string_list(
        doc = "Flags that must appear in the dtc command line, in this order.",
    ),
    "expected_generate_symbols": attr.bool(
        doc = "Expected `BaseDtbInfo.generate_symbols`, if `expect_base_dtb_info`.",
    ),
}

dtb_from_dtb_test = analysistest.make(
    impl = _dtb_from_dtb_test_impl,
    attrs = _ATTRS,
    config_settings = {
        # Take precedence over the toolchain the hub repository registers, so
        # the target under test resolves to a toolchain with `default_dtcopts`.
        "//command_line_option:extra_toolchains": [_TOOLCHAIN],
    },
)

def _dtb_from_dtb_preprocessing_test_impl(ctx):
    env = analysistest.begin(ctx)
    _assert_not_preprocessed(env)
    return analysistest.end(env)

dtb_from_dtb_preprocessing_test = analysistest.make(
    impl = _dtb_from_dtb_preprocessing_test_impl,
    config_settings = {
        "//command_line_option:extra_toolchains": [_PREPROCESSING_TOOLCHAIN],
    },
)

def _dtb_from_dtb_error_test_impl(ctx):
    env = analysistest.begin(ctx)
    asserts.expect_failure(env, ctx.attr.error_message)
    return analysistest.end(env)

dtb_from_dtb_error_test = analysistest.make(
    impl = _dtb_from_dtb_error_test_impl,
    expect_failure = True,
    attrs = {
        "error_message": attr.string(
            doc = "Substring the analysis failure is expected to contain.",
        ),
    },
    config_settings = {
        "//command_line_option:extra_toolchains": [_PREPROCESSING_TOOLCHAIN],
    },
)
