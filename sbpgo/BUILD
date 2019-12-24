load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library", "go_test")

go_library(
    name = "go_default_library",
    srcs = [
        "back.go",
        "corp_context.go",
        "future.go",
        "git.go",
        "hg.go",
        "missing_pwd.go",
        "num_format.go",
        "prompt.go",
        "prompt_main_helper.go",
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
  local = 1,
)

go_test(
    name = "util_test",
    srcs = ["util_test.go"],
    deps = [":go_default_library"],
)

go_test(
    name = "num_format_test",
    srcs = ["num_format_test.go"],
    deps = [":go_default_library"],
)

go_binary(
    name = "back_main",
    srcs = ["back_main.go"],
    visibility = ["//visibility:public"],
    deps = [":go_default_library"],
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
    name = "sleep_main",
    srcs = ["sleep_main.go"],
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

go_binary(
    name = "format_percent_main",
    srcs = ["format_percent_main.go"],
    visibility = ["//visibility:public"],
    deps = [":go_default_library"],
)

go_binary(
    name = "network_usage_main",
    srcs = ["network_usage_main.go"],
    visibility = ["//visibility:public"],
    deps = [":go_default_library"],
)
