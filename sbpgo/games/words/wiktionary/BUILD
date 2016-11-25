load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library")

go_library(
    name = "go_default_library",
    srcs = ["model.go"],
)

go_binary(
    name = "example_main",
    srcs = ["example_main.go"],
    deps = [":go_default_library"],
)
