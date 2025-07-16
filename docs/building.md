# Building devicetrees

After you [installed `rules_devicetree`](installation.md) and
[configured a toolchain](configuring_toolchain.md), you can start building
devicetree blobs (DTB), devicetree blob overlays (DTBO), and composite DTBs.

## Building a base devicetree blob

Use the [`dtb()`](api/dtb.md#dtb) rule to build a base DTB. Example:

```starlark
load("@rules_devicetree//devicetree:dtb.bzl", "dtb")

dtb(
    name = "foo",
    out = "foo.dtb", # optional
    srcs = ["foo.dts"],
)
```

This uses `dtc` to build `foo.dts` as `foo.dtb`.

Note:

- There should be exactly one `.dts` in `srcs`. As a convention,
  `name` should be the same as the `.dts` filename without the extension.
- The `out` attribute is optional. By default, it is `[name].dtb`.

For a concrete example, see
[e2e/smoke/BUILD](../e2e/smoke/BUILD).

### Generating symbols

If overlays will be applied on this base DTB, set `generate_symbols = True`.
This adds `-@` to the `dtc` command. Example:

```
dtb(
    name = "foo",
    srcs = ["foo.dts"],
    generate_symbols = True,
)
```

In `dtb_composite`, applying overlays on a base `dtb()` without
`generate_symbols = True` is an error.

For a concrete example, see
[e2e/smoke/BUILD](../e2e/smoke/BUILD).

### Including `.dtsi` and `.h`

#### Including `.dtsi` and `.h` in the same directory

For `.dtsi` and `.h` in the same directory as the `.dts` file, you may specify
them in `dtb(srcs=)` attribute along with the `.dts` file. Example:

```starlark
dtb(
    name = "foo",
    srcs = [
        "foo.dts",
        "foo.dtsi",
    ],
)
```

```
// In foo.dts:
/include/ "foo.dtsi"
```

For a concrete example, see
[include_files_in_srcs_test](../e2e/smoke/include_test/include_files_in_srcs_test/BUILD.bazel).

#### Including `.dtsi` and `.h` in a different directory (`dtc -i` option)

If the `.dtsi` and `.h` files are in a different directory, and/or you need to
specify `-i` option to `dtc`, use a
[`devicetree_library()`](api/devicetree_library.md#devicetree_library). Example:

```
load("@rules_devicetree//devicetree:devicetree_library.bzl", "devicetree_library")

devicetree_library(
    name = "clk",
    srcs = [
        "include/clk/clk.dtsi",
        "include/clk/dt-bindings.h",
    ],
    includes = [
        "include",
    ],
)
```

Then, add the `devicetree_library` to `dtb(deps=)` attribute. This works
even when the `devicetree_library` is in a different package from where
the `dtb()` target lives. Example:

```starlark
dtb(
    name = "foo",
    srcs = ["foo.dts"],
    deps = [":clk"],
)
```

With this setup, you can `/include/` these files:

```
// foo.dts
/include/ "clk/clk.dtsi"
/include/ "clk/dt-bindings.h"
```

If you enabled
[preprocessing with the C toolchain](configuring_toolchain.md#supporting-c-preprocessor-directives),
you may use `#include` as well. Example:

```
// foo.dts
#include "clk/clk.dtsi"
#include "clk/dt-bindings.h"
```

For a concrete example, see
[e2e/smoke/include_test/c_include_test/BUILD.bazel](../e2e/smoke/include_test/c_include_test/BUILD.bazel).

### Specifying additional flags to dtc

Use the `dtcopts` attribute to specify additional flags to `dtc`. Example:

```starlark
dtb(
    name = "foo",
    srcs = ["foo.dts"],
    dtcopts = ["-a", "4096"],
)
```

Flags are applied in the following order:

1.  `default_dtcopts` from `devicetree_toolchain()` are added.
2.  `dtcopts` from `dtb()` are appended.
3.  `-i` from `includes` of `deps` are appended.

## Building a devicetree blob overlay

Use the [`dtbo()`](api/dtbo.md#dtbo) rule to build a devicetree blob overlay.
The `dtbo()` rule has a similar API to `dtb()`, except that:

- Exactly one `.dtso` file is expected in `srcs`.
- The output is a `.dtbo` file.
- There is no `generate_symbols` attribute.

Example:

```starlark
load("@rules_devicetree//devicetree:dtbo.bzl", "dtbo")

dtbo(
    name = "bar",
    srcs = ["bar.dtso"],
    deps = [":clk"],
    out = "bar.dtbo", # optional
)
```

This uses `dtc` to build `bar.dtso` as `bar.dtbo`.

Similarly, the `out` attribute is optional, and defaults to `[name].dtbo`.

For a concrete example, see
[e2e/smoke/BUILD](../e2e/smoke/BUILD).

## Building a composite DTB

Use the [`dtb_composite()`](api/dtb_composite.md#dtb_composite) rule to
build a composite DTB from a base DTB and a list of DTB overlays. Example:

```starlark
load("@rules_devicetree//devicetree:dtb_composite.bzl", "dtb_composite")

dtb_composite(
    name = "composite",
    base = ":foo",
    overlays = [":bar"],
    out = "composite.dtb", # optional
)
```

This uses `fdtoverlay` to apply `bar.dtbo` on top of `foo.dtb` to create
`composite.dtb`.

Similarly, the `out` attribute is optional, and defaults to `[name].dtb`.

For a concrete example, see
[e2e/smoke/BUILD](../e2e/smoke/BUILD).
