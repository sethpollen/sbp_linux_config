workspace(
  name = "sbp_linux_config",
)

# Import Bazel rules for Go.

http_archive(
    name = "io_bazel_rules_go",
    url = "https://github.com/bazelbuild/rules_go/releases/download/0.9.0/rules_go-0.9.0.tar.gz",
    sha256 = "4d8d6244320dd751590f9100cf39fd7a4b75cd901e1f3ffdfd6f048328883695",
)
load("@io_bazel_rules_go//go:def.bzl", "go_rules_dependencies", "go_register_toolchains")
go_rules_dependencies()
go_register_toolchains()

# Import tools.

git_repository(
    name = "io_bazel_buildifier",
    remote = "https://github.com/bazelbuild/buildifier.git",
    tag = "0.6.0",
)

# Import dependencies.

new_git_repository(
  name = "gomemcache",
  build_file = "BUILD.gomemcache",
  remote = "https://github.com/bradfitz/gomemcache",
  commit = "1952afaa557dc08e8e0d89eafab110fb501c1a2b",
)
