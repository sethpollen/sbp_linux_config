load("@io_bazel_rules_go//go:def.bzl", "go_library", "go_test")

go_library(
  name = "go_default_library",
  srcs = ["format.go"],
  visibility = ["//visibility:public"],
)

go_test(
  name = "format_test",
  srcs = ["format_test.go"],
  library = ":go_default_library",
)
