load("@io_bazel_rules_go//go:def.bzl", "go_binary")

go_binary(
    name = "word_counter_main",
    srcs = ["word_counter_main.go"],
    deps = ["@porterstemmer//:go_default_library"],
)
