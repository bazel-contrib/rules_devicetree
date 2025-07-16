# Installation (Bzlmod)

Note: There are currently no version registered against Bazel Central Registry,
so `bazel_dep()` alone does not work yet. This will work later once we have a
stable release.

Note: Please update the version accordingly.

```starlark
bazel_dep(
   name = "rules_devicetree",
   version = "0.0.0",  # TODO: Update version
)
```

## What if I don't use Bzlmod?

Unfortunately, `rules_devicetree` does not support legacy `WORKSPACE` without
`--enable_bzlmod`. Please consider switching the project to use Bzlmod.

## Next step

Next, [configure a devicetree toolchain](configuring_toolchain.md).
