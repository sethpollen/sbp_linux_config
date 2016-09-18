load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library", "go_test")

go_library(
    name = "go_default_library",
    srcs = [
        "common.go",
    ],
    visibility = ["//visibility:public"],
)

go_binary(
    name = "client_main",
    srcs = ["client_main.go"],
    deps = [":go_default_library"],
    visibility = ["//visibility:public"],
)


go_binary(
    name = "server_main",
    srcs = ["server_main.go"],
    deps = [":go_default_library"],
    visibility = ["//visibility:public"],
)
