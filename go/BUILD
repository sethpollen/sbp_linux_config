load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library", "go_test")

go_library(
    name = "back",
    srcs = ["back.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/back",
    visibility = ["//go:__subpackages__"],
    deps = ["//go/sbpgo:go_default_library"],
)

# Binary invoked by back_main_test.
go_binary(
    name = "back_main_for_test",
    srcs = ["back_main_for_test.go"],
    deps = [":back"],
)

go_test(
    name = "back_main_test",
    srcs = ["back_main_test.go"],
    data = [":back_main_for_test"],
    # This is needed so that 'dtach' can create pseudoterminals during the test.
    local = 1,
    shard_count = 2,
    deps = ["//go/sbpgo:go_default_library"],
)
