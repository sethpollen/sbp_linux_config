load("@io_bazel_rules_go//go:def.bzl", "go_library", "go_test")

go_library(
    name = "go_default_library",
    srcs = [
        "backlight.go",
        "i3status.go",
        "network.go",
        "power_supply.go",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//sbpgo:go_default_library",
    ],
)

go_test(
    name = "network_test",
    srcs = ["network_test.go"],
    data = ["proc-net-dev-sample.txt"],
    deps = [":go_default_library"],
)

go_test(
    name = "power_supply_test",
    srcs = ["power_supply_test.go"],
    data = glob(["power-supply-sample*/*/*"]),
    deps = [":go_default_library"],
)
