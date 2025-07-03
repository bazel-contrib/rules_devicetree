"""Provides a simple way to test your rules as an external workspace.
Add a basic smoke-test target below.
"""

load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@rules_devicetree//devicetree:dtb.bzl", "dtb")
load("@rules_devicetree//devicetree:dtbo.bzl", "dtbo")

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
)

# Test that an empty dtso file can be built.
dtbo(
    name = "empty_overlay",
    srcs = ["empty.dtso"],
)

build_test(
    name = "tests",
    targets = [
        # keep sorted
        ":dtc_version",
        ":empty",
        ":empty_overlay",
    ],
)
