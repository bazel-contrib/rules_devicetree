"""Provides a simple way to test your rules as an external workspace.
Add a basic smoke-test target below.
"""

load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@rules_devicetree//devicetree:dtb.bzl", "dtb")
load("@rules_devicetree//devicetree:dtb_composite.bzl", "dtb_composite")
load("@rules_devicetree//devicetree:dtbo.bzl", "dtbo")
load("@rules_devicetree_test_utils//:fail_analysis_test.bzl", "fail_analysis_test")

# Test that $(DTC) in genrule works.
genrule(
    name = "dtc_version",
    outs = ["dtc_version.txt"],
    cmd = "$(DTC) --version >> $@",
    # On Bazel 8.3 and above, use //devicetree:toolchain_type instead.
    # See https://github.com/bazelbuild/bazel/issues/14009
    toolchains = ["@rules_devicetree//devicetree:resolved_toolchain"],
)

# Test that an empty dts file can be built.
dtb(
    name = "empty",
    srcs = ["empty.dts"],
    generate_symbols = True,
)

# Test that an empty dtso file can be built.
dtbo(
    name = "empty_overlay",
    srcs = ["empty.dtso"],
)

# Test that the empty dtbo can be applied on the empty base dtb
dtb_composite(
    name = "empty_composite",
    base = ":empty",
    overlays = [":empty_overlay"],
)

genrule(
    name = "empty_composite_is_a_file",
    srcs = [":empty_composite"],
    outs = ["empty_composite_is_a_file.txt"],
    cmd = "echo $(execpath :empty_composite) > $@",
)

# Test that #define works.
dtb(
    name = "define",
    srcs = ["define.dts"],
)

# Test that overlays can't be applied on base without symbols.

dtb(
    name = "base_without_symbols",
    srcs = ["empty.dts"],
    generate_symbols = False,
)

dtbo(
    name = "overlay_on_base_without_symbols",
    srcs = ["empty.dtso"],
)

dtb_composite(
    name = "composite_on_base_without_symbols",
    base = ":base_without_symbols",
    overlays = [":overlay_on_base_without_symbols"],
    tags = ["manual"],
)

fail_analysis_test(
    name = "overlay_on_base_without_symbols_should_fail",
    error_message = "{} does not have generate_symbols = True, so overlays can't be applied.".format(
        package_relative_label(":base_without_symbols"),
    ),
    target_under_test = ":composite_on_base_without_symbols",
)

build_test(
    name = "build_tests",
    targets = [
        # keep sorted
        ":define",
        ":dtc_version",
        ":empty",
        ":empty_composite",
        ":empty_composite_is_a_file",
        ":empty_overlay",
    ],
)

test_suite(
    name = "tests",
    # all tests in this package
    tests = None,
)
