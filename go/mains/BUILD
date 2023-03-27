load("@io_bazel_rules_go//go:def.bzl", "go_binary")

go_binary(
    name = "packages_main",
    srcs = ["packages_main.go"],
    deps = ["//go:hosts"],
)

go_binary(
    name = "is_corp_main",
    srcs = ["is_corp_main.go"],
    deps = ["//go:hosts"],
)

go_binary(
    name = "install_main",
    srcs = ["install_main.go"],
    data = [":sbp_main"],
    deps = [
        "//go:fs",
        "//go:hosts",
    ],
)

go_binary(
    name = "sbp_main",
    srcs = ["sbp_main.go"],
    deps = [
        "//go:back",
        "//go:format_percent",
        "//go:i3_gateway",
        "//go:i3blocks_pad",
        "//go:i3blocks_recolor",
        "//go:network_usage",
        "//go:prompt",
        "//go:sleep",
    ],
)
