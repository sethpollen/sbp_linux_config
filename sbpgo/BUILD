load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library", "go_test")

go_library(
    name = "go_default_library",
    srcs = [
        "git.go",
        "environment.go",
        "hg.go",
        "prompt.go",
        "prompt_main_helper.go",
        "shell_flags.go",
        "sleep.go",
        "style.go",
        "tmux.go",
        "util.go",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "@gomemcache//:go_default_library",
    ],
)

go_test(
    name = "environment_test",
    srcs = ["environment_test.go"],
    deps = [":go_default_library"],
)

go_test(
    name = "style_test",
    srcs = ["style_test.go"],
    deps = [":go_default_library"],
)

go_test(
    name = "util_test",
    srcs = ["util_test.go"],
    deps = [":go_default_library"],
)

go_binary(
    name = "desktop_exec_main",
    srcs = ["desktop_exec_main.go"],
    visibility = ["//visibility:public"],
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
    deps = [":go_default_library"],
)

go_binary(
    name = "standard_environment_main",
    srcs = ["standard_environment_main.go"],
    visibility = ["//visibility:public"],
    deps = [":go_default_library"],
)

go_binary(
    name = "tmuxls_main",
    srcs = ["tmuxls_main.go"],
    visibility = ["//visibility:public"],
    deps = [":go_default_library"],
)
