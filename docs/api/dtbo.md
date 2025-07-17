<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Builds device tree blob overlays.

<a id="dtbo"></a>

## dtbo

<pre>
load("@rules_devicetree//devicetree:dtbo.bzl", "dtbo")

dtbo(<a href="#dtbo-name">name</a>, <a href="#dtbo-deps">deps</a>, <a href="#dtbo-srcs">srcs</a>, <a href="#dtbo-out">out</a>, <a href="#dtbo-dtcopts">dtcopts</a>)
</pre>

Build a base devicetree blob overlay (DTBO).

Example:

```starlark
dtbo(
    name = "baz",
    srcs = ["baz.dtso"],
)
```

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="dtbo-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="dtbo-deps"></a>deps |  List of [`devicetree_library()`](devicetree_library.md#devicetree_library) targets for `.dtsi` and `.h` inclusion.<br><br>Order matters. See [`devicetree_library(includes=)`](devicetree_library.md#devicetree_library-includes) for details about ordering of include directories.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="dtbo-srcs"></a>srcs |  List of sources.<br><br>There must be exactly one `.dtso` file.<br><br>`.dtsi` and `.h` files in the same directory or subdirectories may also be specified if you do not need extra search directories (`-i` option to `dtc`). If you do need to pair search directories with `.dtsi` and `.h` files, use [`devicetree_library()`](devicetree_library.md#devicetree_library) and add them to [`deps`](#dtb-deps).   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="dtbo-out"></a>out |  Output file name. This should end with `.dtbo`.<br><br>Default is `name + ".dtbo"`, if name does not end with `.dtbo`; otherwise `name`.   | String | optional |  `""`  |
| <a id="dtbo-dtcopts"></a>dtcopts |  List of flags to dtc.   | List of strings | optional |  `[]`  |


