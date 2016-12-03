load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library")

go_library(
    name = "go_default_library",
    srcs = [
        "inflection.go",
    ],
    data = glob(["*.lua"]),
)

go_binary(
    name = "inflection_main",
    srcs = ["inflection_main.go"],
    deps = [":go_default_library"],
)
