# Copyright (C) 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Common utilities."""

visibility("//devicetree/...")

def _maybe_add_suffix(s, suffix):
    """Adds given suffix if not already having it."""

    if s.endswith(suffix):
        return s
    else:
        return s + suffix

def _check_tool_exists(devicetree_toolchain_info, tool_name):
    """Checks if tool_name exists in devicetree_toolchain_info. If not, fail().

    Args:
        devicetree_toolchain_info: `DevicetreeToolchainInfo` of resolved toolchain
        tool_name: name of the tool, e.g. `"dtc"`
    """
    if not getattr(devicetree_toolchain_info, tool_name, None):
        fail("""The resolved toolchain, {toolchain_label}, does not have {tool_name}.

    - For a custom toolchain, ensure that the {tool_name} attribute is set in
      {toolchain_label}.
    - For the autodetected toolchain, ensure that {tool_name} is in PATH.
""".format(
            toolchain_label = devicetree_toolchain_info.label,
            tool_name = tool_name,
        ))

utils = struct(
    maybe_add_suffix = _maybe_add_suffix,
    check_tool_exists = _check_tool_exists,
)
