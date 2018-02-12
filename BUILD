load("@io_bazel_rules_go//go:def.bzl", "go_prefix")

go_prefix("github.com/sethpollen/sbp_linux_config")

py_library(
    name = "sbp_installer",
    srcs = ["sbp_installer.py"],
    data = [
        "//sbpgo:prompt_main",
        "//sbpgo:sleep_main",
        "//sbpgo:standard_environment_main",
        "//sbpgo:tmuxls_main",
    ],
    visibility = ["//visibility:public"],
)
