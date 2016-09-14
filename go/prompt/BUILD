load("@io_bazel_rules_go//go:def.bzl", "go_library", "go_binary")

# TODO: Run buildifier

go_library(
  name = "go_default_library",
  srcs = ["prompt.go"],
  visibility = ["//visibility:public"],
  deps = [
    "@bradfitz_gomemcache//:go_default_library",
    "//sbp_linux_config/go/format:go_default_library",
    "//sbp_linux_config/go/shell:go_default_library",
  ],
)

go_library(
  name = "main_helper",
  srcs = ["main_helper.go"],
  visibility = ["//visibility:public"],
  deps = [
    ":go_default_library",
    "//sbp_linux_config/go/format:go_default_library",
    "//sbp_linux_config/go/git:go_default_library",
    "//sbp_linux_config/go/util:go_default_library",
  ],
)

go_binary(
  name = "main",
  srcs = ["main.go"],
  deps = [
    ":go_default_library",
    ":main_helper",
    "//sbp_linux_config/go/git:go_default_library",
    "//sbp_linux_config/go/hg:go_default_library",
  ],
)
