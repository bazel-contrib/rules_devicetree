# Configuring toolchains

## Configuring your own devicetree toolchain (recommended)

Invoke the `devicetree_toolchain()` rule to declare a devicetree toolchain. You
need to provide labels to the tools like `dtc`, `fdtoverlay`, etc.

The tools can be a prebuilt binary, a `cc_binary()`, or any
[executable target](https://bazel.build/extending/rules#executable_rules_and_test_rules).

Pseudocode:

BUILD.bazel

```starlark
load("@bazel_skylib//rules:native_binary.bzl", "native_binary")
load("@rules_devicetree//devicetree:toolchain.bzl", "devicetree_toolchain")

filegroup(
    name = "libs",
    srcs = glob(["libs/**/*.so"]),
)

native_binary(
    name = "dtc",
    src = "bin/dtc",
    data = [":libs"],
)

native_binary(
    name = "fdtoverlay",
    src = "bin/fdtoverlay",
    data = [":libs"],
)

devicetree_toolchain(
    name = "devicetree_toolchain",
    dtc = ":dtc",
    fdtoverlay = ":fdtoverlay",
    preprocess = False, # See below
)

toolchain(
    name = "toolchain",
    toolchain = ":devicetree_toolchain",
    toolchain_type = "@rules_devicetree//devicetree:toolchain_type",
)
```

MODULE.bazel

```starlark
register_toolchains("//:toolchain")
```

For a concrete example, see
[e2e/custom_toolchain/BUILD.bazel](../e2e/custom_toolchain/BUILD.bazel)
and
[e2e/custom_toolchain/MODULE.bazel](../e2e/custom_toolchain/MODULE.bazel).


## Using the devicetree toolchain installed on host

If `dtc`, `fdtoverlay` etc. are installed on the machine that executes
the build, you may use those by setting the
`--@rules_devicetree//devicetree:autodetect_toolchain` flag.

Enabling this flag increases the dependency on the execution environment,
making the build less hermetic. Hence, this flag is not enabled by default.

For a concrete example, see
[e2e/smoke/.bazelrc](../e2e/smoke/.bazelrc)

## Using the devicetree toolchain from arbitrary paths

You may use
[`ctx.actions.declare_symlink()`](https://bazel.build/rules/lib/builtins/actions#declare_symlink)
and
[`ctx.actions.symlink()`](https://bazel.build/rules/lib/builtins/actions#symlink)
to use tools at arbitrary paths on the machine that executes the build.

Example:

mytool.bzl

```starlark
def _devicetree_tool_impl(ctx):
    out = ctx.actions.declare_symlink(ctx.label.name)
    ctx.actions.symlink(
        output = out,
        target_path = ctx.attr.path,
        is_executable = True,
    )
    return DefaultInfo(
        files = depset([out]),
        executable = out,
    )

devicetree_tool = rule(
    implementation = _devicetree_tool_impl,
    attrs = {
        "path": attr.string(),
    },
    executable = True,
)
```

BUILD.bazel

```starlark
load(":devicetree_tool.bzl", "devicetree_tool")

devicetree_tool(
    name = "dtc",
    path = "/some/path/bin/dtc",
)

devicetree_tool(
    name = "fdtoverlay",
    path = "/some/path/bin/fdtoverlay",
)

devicetree_toolchain(...)
toolchain(...)
```

## Supporting C preprocessor directives

In `*.dts` and `*.dtso`, to support C preprocessor directives like
`#define` and `#include`, do the following:

1.  Set `devicetree_toolchain(preprocess = True)` if you are using a custom
    devicetree toolchain. Skip this step if you are using the autodetected
    toolchain.
2.  Ensure a C toolchain is registered for the corresponding
    [target platform](https://bazel.build/extending/platforms).

    See
    [Bazel Tutorial: Configure C++ Toolchains](https://bazel.build/tutorials/ccp-toolchain-config)
    for details.

Example:

```
devicetree_toolchain(
    name = "devicetree_toolchain",
    dtc = ":dtc",
    fdtoverlay = ":fdtoverlay",
    preprocess = True,
)
```
