<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Headers and include directories of a devicetree target.

<a id="DevicetreeInfo"></a>

## DevicetreeInfo

<pre>
load("@rules_devicetree//devicetree:devicetree_info.bzl", "DevicetreeInfo")

DevicetreeInfo(<a href="#DevicetreeInfo-hdrs">hdrs</a>, <a href="#DevicetreeInfo-includes">includes</a>)
</pre>

Headers and include directories of a devicetree target.

Any rule may return this provider to make its generated `.dtsi` and
`.h` files usable from the `deps` of
[`dtb()`](dtb.md#dtb) and [`dtbo()`](dtbo.md#dtbo); it is not limited
to [`devicetree_library()`](devicetree_library.md#devicetree_library).

Both depsets must be constructed with `order = "postorder"` so that
include directories from dependencies precede those of the target
itself. See
[`devicetree_library(includes=)`](devicetree_library.md#devicetree_library-includes).

**FIELDS**

| Name  | Description |
| :------------- | :------------- |
| <a id="DevicetreeInfo-hdrs"></a>hdrs |  (`depset` of `File`) Header files (`.h`, `.dtsi`) made available to dependents, including those of dependencies. These become inputs of the preprocessor and `dtc` actions.    |
| <a id="DevicetreeInfo-includes"></a>includes |  (`depset` of `File`) Directories added to the preprocessor (`-I`) and `dtc` (`-i`) search path, including those of dependencies. These are `File`s of directories, not of files.    |


