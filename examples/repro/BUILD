load("//apple:ios.bzl", "ios_unit_test")
load("//apple:resources.bzl", "apple_resource_bundle")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

ios_unit_test(
    name = "FooTests",
    minimum_os_version = "13.0",
    deps = [":FooTestsLib"],
)

swift_library(
    name = "FooTestsLib",
    srcs = ["FooTests.swift"],
    deps = [":FooLib"],
)

swift_library(
    name = "FooLib",
    srcs = ["Foo.swift"],
    data = [":FooBundle"],
)

apple_resource_bundle(
    name = "FooBundle",
    bundle_name = "Foo",
    resources = glob(["Foo.xcdatamodeld/**"]),
)