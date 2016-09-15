load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library", "go_test")

go_library(
    name = "go_default_library",
    visibility = ["//visibility:public"],
    srcs = [
      "format.go",
      "git.go",
      "hg.go",
      "prompt.go",
      "prompt_main_helper.go",
      "shell.go",
      "util.go",
    ],
    deps = ["@gomemcache//:go_default_library"],
)

go_test(
    name = "format_test",
    srcs = ["format_test.go"],
    deps = [":go_default_library"],
)

go_test(
    name = "shell_test",
    srcs = ["shell_test.go"],
    deps = [":go_default_library"],
)

go_test(
    name = "util_test",
    srcs = ["util_test.go"],
    deps = [":go_default_library"],
)

go_binary(
    name = "prompt_main",
    visibility = ["//visibility:public"],
    srcs = ["prompt_main.go"],
    deps = [":go_default_library"],
)

go_binary(
    name = "sleep_main",
    visibility = ["//visibility:public"],
    srcs = ["sleep_main.go"],
)