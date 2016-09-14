load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library", "go_test")

go_library(
  name = "go_default_library",
  srcs = ["util.go"],
  deps = ["@bradfitz_gomemcache//:go_default_library"],
  visibility = ["//visibility:public"],
)

go_test(
  name = "util_test",
  srcs = ["util_test.go"],
  library = ":go_default_library",
)
