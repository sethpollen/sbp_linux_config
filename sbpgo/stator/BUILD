load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library", "go_test")

go_library(
    name = "go_default_library",
    srcs = [
        "backlight.go",
        "network.go",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//sbpgo:go_default_library",
    ],
)

go_test(
    name = "network_test",
    srcs = ["network_test.go"],
    deps = [":go_default_library"],
    data = ["proc-net-dev-sample.txt"],
)
