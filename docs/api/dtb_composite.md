<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Builds a composite dtb by applying overlays on a base dtb.

<a id="dtb_composite"></a>

## dtb_composite

<pre>
load("@rules_devicetree//devicetree:dtb_composite.bzl", "dtb_composite")

dtb_composite(<a href="#dtb_composite-name">name</a>, <a href="#dtb_composite-out">out</a>, <a href="#dtb_composite-base">base</a>, <a href="#dtb_composite-overlays">overlays</a>)
</pre>

Builds a composite dtb by applying overlays on a base dtb.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="dtb_composite-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="dtb_composite-out"></a>out |  Output file name.<br><br>Default is `name + ".dtb"` if missing extension, otherwise `name`.   | String | optional |  `""`  |
| <a id="dtb_composite-base"></a>base |  Base `.dtb` to apply overlays on.<br><br>This usually comes from a `dtb()` target with `generate_symbols = True`.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="dtb_composite-overlays"></a>overlays |  List of `.dtbo` overlays to apply.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |


