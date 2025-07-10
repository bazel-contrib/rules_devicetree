"""This module implements the language-specific toolchain rule.
"""

load("@rules_devicetree//devicetree/private:toolchain.bzl", _devicetree_toolchain = "devicetree_toolchain")

devicetree_toolchain = _devicetree_toolchain
