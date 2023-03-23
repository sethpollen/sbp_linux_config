# Go programs which are part of my Linux environment.

load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library", "go_test")

# TODO: Give this a better name. Maybe just "sbpgo".
go_library(
    name = "go_default_library",
    srcs = [
        "back.go",
        "dmenu.go",
        "format_percent.go",
        "future.go",
        "git.go",
        "hg.go",
        "i3_gateway.go",
        "i3blocks_pad.go",
        "i3blocks_recolor.go",
        "network_usage.go",
        "num_format.go",
        "p4.go",
        "prompt.go",
        "prompt_builder.go",
        "shm.go",
        "sleep.go",
        "style.go",
        "util.go",
        "workspace.go",
    ],
    importpath = "github.com/sethpollen/sbp_linux_config/sbpgo",
    visibility = ["//visibility:public"],
)

# Binary invoked by back_main_test.
go_binary(
    name = "back_main_for_test",
    srcs = ["back_main_for_test.go"],
    deps = [":go_default_library"],
)

go_test(
    name = "back_main_test",
    srcs = ["back_main_test.go"],
    data = [":back_main_for_test"],
    # This is needed so that 'dtach' can create pseudoterminals during the test.
    local = 1,
    deps = [":go_default_library"],
)

go_test(
    name = "future_test",
    srcs = ["future_test.go"],
    deps = [":go_default_library"],
)

go_test(
    name = "num_format_test",
    srcs = ["num_format_test.go"],
    deps = [":go_default_library"],
)

go_binary(
    name = "sbpgo_main",
    srcs = ["sbpgo_main.go"],
    visibility = ["//visibility:public"],
    deps = [":go_default_library"],
)
