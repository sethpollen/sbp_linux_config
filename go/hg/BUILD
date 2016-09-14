load("@io_bazel_rules_go//go:def.bzl", "go_library")

go_library(
  name = "go_default_library",
  srcs = ["hg.go"],
  deps = [
    "//sbp_linux_config/go/format:go_default_library",
    "//sbp_linux_config/go/prompt:go_default_library",
    "//sbp_linux_config/go/util:go_default_library",
  ],
  visibility = ["//visibility:public"],
)

