workspace(
  name = "sbp_linux_config",
)

http_archive(
    name = "io_bazel_rules_go",
    url = "https://github.com/bazelbuild/rules_go/releases/download/0.12.0/rules_go-0.12.0.tar.gz",
    sha256 = "c1f52b8789218bb1542ed362c4f7de7052abcf254d865d96fb7ba6d44bc15ee3",
)

http_archive(
    name = "com_github_bazelbuild_buildtools",
    url = "https://github.com/bazelbuild/buildtools/archive/0.15.0.zip",
    strip_prefix = "buildtools-0.15.0",
)

new_http_archive(
    name = "gomemcache",
    build_file = "BUILD.gomemcache",
    url = "https://github.com/bradfitz/gomemcache/archive/master.zip",
    strip_prefix = "gomemcache-master",
)

load("@io_bazel_rules_go//go:def.bzl", "go_rules_dependencies", "go_register_toolchains")

go_rules_dependencies()
go_register_toolchains()

