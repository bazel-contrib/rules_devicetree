# Installation (Bzlmod)

Please update the version accordingly.
For the most recent release, refer to
[https://registry.bazel.build/modules/rules_devicetree](https://registry.bazel.build/modules/rules_devicetree)
to update the version.

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
