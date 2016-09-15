workspace(
  name = "sbp_linux_config",
)

# Import Bazel rules for Go.

git_repository(
    name = "io_bazel_rules_go",
    remote = "https://github.com/bazelbuild/rules_go.git",
    tag = "0.1.0",
)
load("@io_bazel_rules_go//go:def.bzl", "go_repositories", "go_prefix")
go_repositories()

# Import dependencies.

new_git_repository(
  name = "gomemcache",
  build_file = "BUILD.gomemcache",
  commit = "fb1f79c6b65acda83063cbc69f6bba1522558bfc",
  remote = "https://github.com/bradfitz/gomemcache",
)
