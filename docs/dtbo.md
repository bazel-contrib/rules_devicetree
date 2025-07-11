<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Builds device tree blob overlays.

<a id="dtbo"></a>

## dtbo

<pre>
load("@rules_devicetree//devicetree:dtbo.bzl", "dtbo")

dtbo(<a href="#dtbo-name">name</a>, <a href="#dtbo-srcs">srcs</a>, <a href="#dtbo-out">out</a>, <a href="#dtbo-dtcopts">dtcopts</a>)
</pre>

Build a base devicetree blob overlay (DTBO).

Example:

```starlark
dtbo(
    name = "baz",
    srcs = [
        "baz.dtso",
        "bar.dtsi",
    ],
)
```

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="dtbo-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="dtbo-srcs"></a>srcs |  List of sources.<br><br>There must be exactly one `.dtso` file. Beside the `.dtso` file, extra include files like `.dtsi` can be specified.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="dtbo-out"></a>out |  Output file name. This should end with `.dtbo`.<br><br>Default is `name + ".dtbo"`, if name does not end with `.dtbo`; otherwise `name`.   | String | optional |  `""`  |
| <a id="dtbo-dtcopts"></a>dtcopts |  List of flags to dtc.   | List of strings | optional |  `[]`  |


