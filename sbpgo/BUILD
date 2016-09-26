load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library", "go_test")

go_library(
    name = "go_default_library",
    srcs = [
        "format.go",
        "git.go",
        "hg.go",
        "num_format.go",
        "prompt.go",
        "prompt_main_helper.go",
        "rate.go",
        "shell_export.go",
        "util.go",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//sbpgo/conch:go_default_library",
        "@gomemcache//:go_default_library",
    ],
)

go_test(
    name = "format_test",
    srcs = ["format_test.go"],
    deps = [":go_default_library"],
)

go_test(
    name = "num_format_test",
    srcs = ["num_format_test.go"],
    deps = [":go_default_library"],
)

go_test(
    name = "rate_test",
    srcs = ["rate_test.go"],
    deps = [":go_default_library"],
)

go_test(
    name = "shell_export_test",
    srcs = ["shell_export_test.go"],
    deps = [":go_default_library"],
)

go_test(
    name = "util_test",
    srcs = ["util_test.go"],
    deps = [":go_default_library"],
)

go_binary(
    name = "prompt_main",
    srcs = ["prompt_main.go"],
    visibility = ["//visibility:public"],
    deps = [":go_default_library"],
)

go_binary(
    name = "sleep_main",
    srcs = ["sleep_main.go"],
    visibility = ["//visibility:public"],
)
