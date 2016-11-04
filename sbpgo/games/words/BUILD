load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library", "go_test")

go_library(
    name = "go_default_library",
    srcs = ["wordlist.go"],
    data = ["top-5000-words.csv"],
)

go_test(
    name = "wordlist_test",
    srcs = ["wordlist_test.go"],
    deps = [":go_default_library"],
)
