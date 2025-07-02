#!/bin/bash -e
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

if [ ! -n "${1}" ]; then
    echo "ERROR: Missing file argument" >&2
    exit 1
fi
file="${1}"

if [ ! -n "${2}" ]; then
    echo "ERROR: Missing expected_size argument" >&2
    exit 1
fi
expected_size="${2}"

if [ ! -f "${file}" ]; then
    echo "ERROR: File ${file} does not exist" >&2
    exit 1
fi

actual_size=$(wc -c < "${file}")
if [ "${actual_size}" -ne "${2}" ]; then
    echo "ERROR: Actual size of ${file} is ${actual_size}, expected ${expected_size}" >&2
    exit 1
fi
