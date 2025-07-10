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

"""Information about how to invoke the tool executable."""

load("//devicetree/private:constants.bzl", "TOOLCHAIN_TOOLS")

visibility("//devicetree/...")

DevicetreeToolchainInfo = provider(
    doc = "Information about how to invoke the tool executable.",
    fields = {
        name: "Executable of {} for the target platform.".format(name)
        for name in TOOLCHAIN_TOOLS
    } | {
        "default_dtcopts": "Default list of flags to dtc",
        "preprocess": """Whether source files are preprocessed.

            None means it is dependent on whether the C toolchain is available.""",
    },
)
