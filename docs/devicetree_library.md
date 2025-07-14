<!-- Generated with Stardoc: http://skydoc.bazel.build -->

A library of `.dtsi` and `.h` files that can be used in [`dtb()`](dtb.md#dtb)
and [`dtbo()`](dtbo.md#dtbo).

<a id="devicetree_library"></a>

## devicetree_library

<pre>
load("@rules_devicetree//devicetree:devicetree_library.bzl", "devicetree_library")

devicetree_library(<a href="#devicetree_library-name">name</a>, <a href="#devicetree_library-deps">deps</a>, <a href="#devicetree_library-hdrs">hdrs</a>, <a href="#devicetree_library-includes">includes</a>)
</pre>

A library of `.dtsi` and `.h` files that can be used in
[`dtb()`](dtb.md#dtb) and [`dtbo()`](dtbo.md#dtbo).

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="devicetree_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="devicetree_library-deps"></a>deps |  Transitive `devicetree_library()` targets.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="devicetree_library-hdrs"></a>hdrs |  List of exported included files (`.h`, `.dtsi`).<br><br>These files are visible to all targets that transitively depend on this target.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="devicetree_library-includes"></a>includes |  List of exported include directories in the current package.<br><br>These `-i` are added to all [`dtb()`](dtb.md#dtb) and [`dtbo()`](dtbo.md#dtbo) targets that transitively depend on this target.<br><br>These should be labels to **directories**, not files. For example:<br><br><pre><code class="language-starlark">devicetree_library(&#10;    name = "mylib",&#10;    hdrs = ["include/myfile.dtsi"],&#10;    includes = ["include"],&#10;)</code></pre><br><br>**Ordering**<br><br>Include directories are collected with `postorder` traversal; that is, `includes` from dependencies are added first, then `includes` from this target are added.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |


