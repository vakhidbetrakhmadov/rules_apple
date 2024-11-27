load("//apple:ios.bzl", "ios_unit_test", "ios_application")
load("//apple:resources.bzl", "apple_resource_bundle")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

ios_application(
    name = "FooApp",
    deps = [":FooAppLib"],
    bundle_id = "com.example.foo-app",
    app_icons = ["//examples/resources:PhoneAppIcon.xcassets"],
    infoplists = [":Info.plist"],
    families = ["iphone", "ipad",],
    minimum_os_version = "15.0",
)

swift_library(
    name = "FooAppLib",
    module_name = "FooApp",
    srcs = ["FooApp.swift"],
    deps = [":Foo"],
)

ios_unit_test(
    name = "FooTests",
    minimum_os_version = "13.0",
    deps = [":FooTestsLib"],
)

swift_library(
    name = "FooTestsLib",
    module_name = "FooTests",
    srcs = ["FooTests.swift"],
    deps = [":Foo"],
)

swift_library(
    name = "Foo",
    module_name = "Foo",
    srcs = ["Foo.swift"],
    data = [":FooBundle"],
)

apple_resource_bundle(
    name = "FooBundle",
    bundle_name = "Foo",
    resources = glob(["Foo.xcdatamodeld/**"]),
)