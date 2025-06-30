"""Provides a simple way to test your rules as an external workspace.
Add a basic smoke-test target below.
"""

load("@bazel_skylib//rules:build_test.bzl", "build_test")

# Test that $(DTC) in genrule works.
genrule(
    name = "dtc_version",
    outs = ["dtc_version.txt"],
    cmd = "$(DTC) --version >> $@",
    # On Bazel 8.3 and above, use //devicetree:toolchain_type instead.
    # See https://github.com/bazelbuild/bazel/issues/14009
    toolchains = ["@rules_devicetree//devicetree:resolved_toolchain"],
)

build_test(
    name = "tests",
    targets = [
        ":dtc_version",
    ],
)
