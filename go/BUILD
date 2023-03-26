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
        ":format_percent",
        ":i3_gateway",
        ":i3blocks_pad",
        ":i3blocks_recolor",
        ":network_usage",
        ":prompt",
        ":sleep",
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
    deps = [":futures"],
)

go_library(
    name = "i3blocks_pad",
    srcs = ["i3blocks_pad.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/i3blocks_pad",
    deps = [
        ":read_stdin",
        ":shm",
    ],
)

go_library(
    name = "i3blocks_recolor",
    srcs = ["i3blocks_recolor.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/i3blocks_recolor",
    deps = [":read_stdin"],
)

go_library(
    name = "i3_gateway",
    srcs = ["i3_gateway.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/i3_gateway",
    deps = [":dmenu"],
)

go_library(
    name = "dmenu",
    srcs = ["dmenu.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/dmenu",
)

go_library(
    name = "futures",
    srcs = ["futures.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/futures",
    deps = [":fs"],
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
        ":fs",
        ":futures",
        ":git",
        ":hg",
        ":p4",
        ":style",
        ":workspace",
    ],
)

go_library(
    name = "git",
    srcs = ["git.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/git",
    deps = [
        ":futures",
        ":workspace",
    ],
)

go_library(
    name = "hg",
    srcs = ["hg.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/hg",
    deps = [
        ":futures",
        ":workspace",
    ],
)

go_library(
    name = "p4",
    srcs = ["p4.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/p4",
    deps = [
        ":futures",
        ":workspace",
    ],
)

go_library(
    name = "num_format",
    srcs = ["num_format.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/num_format",
)

go_test(
    name = "num_format_test",
    srcs = ["num_format_test.go"],
    deps = [":num_format"],
)

go_library(
    name = "format_percent",
    srcs = ["format_percent.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/format_percent",
    deps = [
        ":num_format",
        ":read_stdin",
        ":shm",
    ],
)

go_library(
    name = "network_usage",
    srcs = ["network_usage.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/network_usage",
    deps = [
        ":num_format",
        ":shm",
    ],
)

go_library(
    name = "fs",
    srcs = ["fs.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/fs",
)

go_library(
    name = "shm",
    srcs = ["shm.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/shm",
)

go_library(
    name = "style",
    srcs = ["style.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/style",
)

go_library(
    name = "workspace",
    srcs = ["workspace.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/workspace",
    deps = [":fs"],
)

go_library(
    name = "sleep",
    srcs = ["sleep.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/sleep",
)

go_library(
    name = "read_stdin",
    srcs = ["read_stdin.go"],
    importpath = "github.com/sethpollen/sbp_linux_config/read_stdin",
)
