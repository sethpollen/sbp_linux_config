load("@io_bazel_rules_go//go:def.bzl", "go_library")

# TODO: binary

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

