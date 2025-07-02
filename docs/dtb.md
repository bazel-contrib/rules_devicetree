<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Builds device tree blobs.

<a id="dtb"></a>

## dtb

<pre>
load("@rules_devicetree//devicetree:dtb.bzl", "dtb")

dtb(<a href="#dtb-name">name</a>, <a href="#dtb-srcs">srcs</a>, <a href="#dtb-out">out</a>, <a href="#dtb-dtcopts">dtcopts</a>, <a href="#dtb-generate_symbols">generate_symbols</a>)
</pre>

Build a base devicetree blob (DTB).

Example:

```starlark
dtb(
    name = "foo",
    srcs = [
        "foo.dts",
        "bar.dtsi",
    ],
)
```

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="dtb-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="dtb-srcs"></a>srcs |  List of sources.<br><br>There must be exactly one `.dts` file. Beside the `.dts` file, extra include files like `.dtsi` can be specified.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="dtb-out"></a>out |  Output file name. This should end with `.dtb`.<br><br>Default is `name + ".dtb"`, if name does not end with `.dtb`; otherwise `name`.   | String | optional |  `""`  |
| <a id="dtb-dtcopts"></a>dtcopts |  List of flags to dtc.   | List of strings | optional |  `[]`  |
| <a id="dtb-generate_symbols"></a>generate_symbols |  Enable generation of symbols (-@).<br><br>This is necessary if you are applying overlays on top of it.   | Boolean | optional |  `False`  |


