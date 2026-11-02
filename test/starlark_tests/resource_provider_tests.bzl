# Copyright 2026 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Tests resource provider nesting and Swift module inheritance."""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load(
    "//apple/internal:providers.bzl",  # buildifier: disable=bzl-visibility
    "new_appleresourceinfo",
)
load(
    "//apple/internal:resources.bzl",  # buildifier: disable=bzl-visibility
    "resources",
)

def _resource_provider_swift_module_test_impl(ctx):
    env = unittest.begin(ctx)
    files = depset(["resource"])

    # Each entry supplies an input directory/module and the expected module with a default set.
    cases = [
        (None, None, "ResourceModel"),
        ("it.lproj", None, "ResourceModel"),
        ("subdir/it.lproj", None, "ResourceModel"),
        (None, "LibraryModule", "LibraryModule"),
        ("Nested.bundle", None, None),
        ("Nested.bundle/it.lproj", None, None),
        ("subdir/Nested.bundle/it.lproj", None, None),
        ("Nested.bundle", "NestedModule", "NestedModule"),
    ]
    buckets = {
        field: [(parent_dir, module, files) for parent_dir, module, _ in cases]
        for field in ["datamodels", "storyboards", "xibs"]
    }
    buckets["strings"] = [(None, None, files)]
    buckets["processed"] = [(None, None, files)]
    provider = new_appleresourceinfo(
        owners = depset(),
        unowned_resources = depset(),
        **buckets
    )
    if ctx.attr.operation == "merge":
        updated_provider = resources.merge_providers(
            default_swift_module = ctx.attr.swift_module or None,
            providers = [provider],
        )
    else:
        updated_provider = resources.nest_in_bundle(
            default_swift_module = ctx.attr.swift_module or None,
            nesting_bundle_dir = "Outer.bundle",
            provider_to_nest = provider,
        )
    for field in ["datamodels", "storyboards", "xibs"]:
        actual = getattr(updated_provider, field)
        for index, (parent_dir, module, expected_module) in enumerate(cases):
            expected_parent = parent_dir
            if ctx.attr.operation == "nest":
                expected_parent = "Outer.bundle/" + parent_dir if parent_dir else "Outer.bundle"
            asserts.equals(env, expected_parent, actual[index][0])
            asserts.equals(env, expected_module if ctx.attr.swift_module else module, actual[index][1])
            asserts.equals(env, files.to_list(), actual[index][2].to_list())
    for field in ["strings", "processed"]:
        actual = getattr(updated_provider, field)
        asserts.equals(env, "Outer.bundle" if ctx.attr.operation == "nest" else None, actual[0][0])
        asserts.equals(env, None, actual[0][1])
        asserts.equals(env, files.to_list(), actual[0][2].to_list())
    return unittest.end(env)

_resource_provider_swift_module_test = unittest.make(
    _resource_provider_swift_module_test_impl,
    attrs = {
        "operation": attr.string(default = "nest", values = ["nest", "merge"]),
        "swift_module": attr.string(),
    },
)

def resource_provider_test_suite(name):
    """Tests module defaults while preserving library modules and nested bundle boundaries.

    Args:
        name: The name of the test suite.
    """
    _resource_provider_swift_module_test(
        name = name + "_nest_in_bundle_swift_module_test",
        swift_module = "ResourceModel",
    )
    _resource_provider_swift_module_test(
        name = name + "_nest_in_bundle_without_swift_module_test",
    )
    _resource_provider_swift_module_test(
        name = name + "_merge_swift_module_test",
        operation = "merge",
        swift_module = "ResourceModel",
    )
    _resource_provider_swift_module_test(
        name = name + "_merge_without_swift_module_test",
        operation = "merge",
    )
    native.test_suite(
        name = name,
        tests = [
            name + "_merge_swift_module_test",
            name + "_merge_without_swift_module_test",
            name + "_nest_in_bundle_swift_module_test",
            name + "_nest_in_bundle_without_swift_module_test",
        ],
    )
