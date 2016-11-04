load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library", "go_test")

go_binary(
    name = "embed_wordlist_main",
    srcs = ["embed_wordlist_main.go"],
    deps = ["//sbpgo/games/words:go_default_library"],
)

genrule(
    name = "embed_wordlist",
    srcs = ["top-5000-words.csv"],
    outs = ["embedded_wordlist.go"],
    cmd = "./$(location embed_wordlist_main)" +
          "  --source_file=\"$(location top-5000-words.csv)\"" +
          "  --dest_file=\"$@\"",
    tools = ["embed_wordlist_main"],
)

go_library(
    name = "go_default_library",
    srcs = [":embed_wordlist"],
    deps = ["//sbpgo/games/words:go_default_library"],
    visibility = ["//visibility:public"],
)
