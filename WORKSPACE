workspace(
  name = "sbp_linux_config",
)

# Import Bazel rules for Go.

git_repository(
    name = "io_bazel_rules_go",
    remote = "https://github.com/bazelbuild/rules_go.git",
    tag = "0.8.0",
)
load("@io_bazel_rules_go//go:def.bzl", "go_repositories", "go_prefix")
go_repositories()

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
