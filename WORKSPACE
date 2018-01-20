workspace(
  name = "sbp_linux_config",
)

http_archive(
    name = "io_bazel_rules_go",
    url = "https://github.com/bazelbuild/rules_go/releases/download/0.9.0/rules_go-0.9.0.tar.gz",
    sha256 = "4d8d6244320dd751590f9100cf39fd7a4b75cd901e1f3ffdfd6f048328883695",
)

# TODO: replace usage of git_repository with http_archive

http_archive(
    name = "com_github_bazelbuild_buildtools",
    strip_prefix = "buildtools-0.6.0",
    url = "https://github.com/bazelbuild/buildtools/archive/0.6.0.tar.gz",
)

new_git_repository(
  name = "gomemcache",
  build_file = "BUILD.gomemcache",
  remote = "https://github.com/bradfitz/gomemcache",
  commit = "1952afaa557dc08e8e0d89eafab110fb501c1a2b",
)

load("@io_bazel_rules_go//go:def.bzl", "go_rules_dependencies", "go_register_toolchains")

go_rules_dependencies()
go_register_toolchains()

