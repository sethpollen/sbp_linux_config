workspace(
  name = "sbp_linux_config",
)

# Import Bazel rules for Go.

git_repository(
    name = "io_bazel_rules_go",
    remote = "https://github.com/bazelbuild/rules_go.git",
    tag = "0.3.0",
)
load("@io_bazel_rules_go//go:def.bzl", "go_repositories", "go_prefix")
go_repositories()

# Import tools.

git_repository(
    name = "io_bazel_buildifier",
    remote = "https://github.com/bazelbuild/buildifier.git",
    commit = "251fa7607cb9da4c9b3505af634ae1e11517d987",
)

# Import dependencies.

new_git_repository(
  name = "gomemcache",
  build_file = "BUILD.gomemcache",
  remote = "https://github.com/bradfitz/gomemcache",
  commit = "fb1f79c6b65acda83063cbc69f6bba1522558bfc",
)
