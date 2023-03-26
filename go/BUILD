load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library", "go_test")

go_binary(
    name = "install_main",
    srcs = ["install_main.go"],
    data = [":sbp_main"],
)

go_binary(
    name = "sbp_main",
    srcs = ["sbp_main.go"],
    deps = [
        ":back",
        ":i3_gateway",
        ":i3blocks_pad",
        ":i3blocks_recolor",
        ":prompt",
        "//go/sbpgo:go_default_library",
    ],
)

go_library(
    name = "back",
    srcs = ["back.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/back",
    # TODO: remove this
    visibility = ["//go:__subpackages__"],
    deps = [":futures"],
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
    deps = [
        ":futures",
        "//go/sbpgo:go_default_library",
    ],
)

go_library(
    name = "i3blocks_pad",
    srcs = ["i3blocks_pad.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/i3blocks_pad",
    deps = ["//go/sbpgo:go_default_library"],
)

go_library(
    name = "i3blocks_recolor",
    srcs = ["i3blocks_recolor.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/i3blocks_recolor",
    deps = ["//go/sbpgo:go_default_library"],
)

go_library(
    name = "i3_gateway",
    srcs = ["i3_gateway.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/i3_gateway",
    deps = [
        ":dmenu",
        "//go/sbpgo:go_default_library",
    ],
)

go_library(
    name = "dmenu",
    srcs = ["dmenu.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/dmenu",
    deps = ["//go/sbpgo:go_default_library"],
)

go_library(
    name = "futures",
    srcs = ["futures.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/futures",
    deps = ["//go/sbpgo:go_default_library"],
)

go_test(
    name = "futures_test",
    srcs = ["futures_test.go"],
    deps = [":futures"],
)

go_library(
    name = "prompt",
    srcs = ["prompt.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/prompt",
    deps = [
        ":futures",":git",":hg",":p4",
        ":prompt_builder",
        "//go/sbpgo:go_default_library",
    ],
)

go_library(
    name = "prompt_builder",
    srcs = ["prompt_builder.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/prompt_builder",
    deps = [
        ":futures",
        "//go/sbpgo:go_default_library",
    ],
)

go_library(
    name = "git",
    srcs = ["git.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/git",
    deps = [
        ":futures",
        "//go/sbpgo:go_default_library",
    ],
)

go_library(
    name = "hg",
    srcs = ["hg.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/hg",
    deps = [
        ":futures",
        "//go/sbpgo:go_default_library",
    ],
)

go_library(
    name = "p4",
    srcs = ["p4.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/p4",
    deps = [
        ":futures",
        "//go/sbpgo:go_default_library",
    ],
)
