load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library")

go_library(
    name = "go_default_library",
    srcs = [
        "extractor.go",
    ],
)

go_binary(
    name = "extractor_main",
    srcs = ["extractor_main.go"],
    deps = [":go_default_library"],
)
