load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library", "go_test")

go_library(
    name = "go_default_library",
    srcs = [
        "sampler.go",
        "wordlist.go",
    ],
    visibility = ["//visibility:public"],
)

go_test(
    name = "wordlist_test",
    srcs = ["wordlist_test.go"],
    deps = [
        ":go_default_library",
        "//sbpgo/games/words/embed:go_default_library",
    ],
)

go_test(
    name = "sampler_test",
    srcs = ["sampler_test.go"],
    deps = [
        ":go_default_library",
        "//sbpgo/games/words/embed:go_default_library",
    ],
)

go_binary(
    name = "words_main",
    srcs = ["words_main.go"],
    deps = [
        ":go_default_library",
        "//sbpgo:go_default_library",
        "//sbpgo/games/words/embed:go_default_library",
    ],
)
