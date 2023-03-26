# Go programs which are part of my Linux environment.

load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library", "go_test")

# TODO: Give this a better name. Maybe just "sbpgo".
go_library(
    name = "go_default_library",
    srcs = [
        "shm.go",
        "sleep.go",
        "style.go",
        "util.go",
        "workspace.go",
    ],
    importpath = "github.com/sethpollen/sbp_linux_config/sbpgo",
    visibility = ["//visibility:public"],
)
