load("@io_bazel_rules_go//go:def.bzl", "go_binary")

py_binary(
    name = "install",
    srcs = ["install.py"],
)

# TODO: rename to just "install".
go_binary(
    name = "install2",
    srcs = ["install.go"],
    data = ["//sbpgo:sbpgo_main"],
)
