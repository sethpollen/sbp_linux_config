load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library")

go_library(
    name = "go_default_library",
    srcs = [
        "inflection.go",
    ],
    data = glob(["*.lua"]),
)

go_binary(
    name = "lua_main",
    srcs = ["lua_main.go"],
    deps = [":go_default_library"],
)
