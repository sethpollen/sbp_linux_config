load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library", "go_test")

go_library(
    name = "go_default_library",
    srcs = [
        "client.go",
        "common.go",
        "server.go",
    ],
    visibility = ["//visibility:public"],
)

go_test(
    name = "common_test",
    srcs = ["common_test.go"],
    deps = [":go_default_library"],
)

go_binary(
    name = "server_main",
    srcs = ["server_main.go"],
    visibility = ["//visibility:public"],
    deps = [":go_default_library"],
)
