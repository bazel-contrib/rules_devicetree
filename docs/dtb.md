<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Builds device tree blobs.

<a id="dtb"></a>

## dtb

<pre>
dtb(<a href="#dtb-name">name</a>, <a href="#dtb-out">out</a>, <a href="#dtb-srcs">srcs</a>, <a href="#dtb-symbols">symbols</a>)
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
| <a id="dtb-out"></a>out |  Output file name. This should end with <code>.dtb</code>.<br><br>                Default is <code>name + ".dtb"</code>, if name does not end with <code>.dtb</code>;                 otherwise <code>name</code>.   | String | optional | <code>""</code> |
| <a id="dtb-srcs"></a>srcs |  List of sources.<br><br>            There must be exactly one <code>.dts</code> file. Beside the <code>.dts</code> file,             extra include files like <code>.dtsi</code> can be specified.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |
| <a id="dtb-symbols"></a>symbols |  Enable generation of symbols (-@).<br><br>            This is necessary if you are applying overlays on top of it.   | Boolean | optional | <code>False</code> |


