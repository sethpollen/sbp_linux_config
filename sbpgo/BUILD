load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library", "go_test")

go_library(
    name = "go_default_library",
    srcs = [
        "back.go",
        "corp_context.go",
        "format_percent.go",
        "future.go",
        "git.go",
        "hg.go",
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

go_test(
    name = "back_main_test",
    srcs = ["back_main_test.go"],
    data = [":back_main_for_test"],
    # This is needed so that 'dtach' can create pseudoterminals during the test.
    local = 1,
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
    deps = [":go_default_library"]
)

go_binary(
    name = "back_main_for_test",
    srcs = ["back_main_for_test.go"],
    deps = [":go_default_library"],
)

go_binary(
    name = "prompt_main",
    srcs = ["prompt_main.go"],
    visibility = ["//visibility:public"],
    deps = [":go_default_library"],
)

go_binary(
    name = "i3blocks_pad_main",
    srcs = ["i3blocks_pad_main.go"],
    visibility = ["//visibility:public"],
    deps = [":go_default_library"],
)

go_binary(
    name = "i3blocks_recolor_main",
    srcs = ["i3blocks_recolor_main.go"],
    visibility = ["//visibility:public"],
    deps = [":go_default_library"],
)

