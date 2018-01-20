workspace(
  name = "sbp_linux_config",
)

http_archive(
    name = "io_bazel_rules_go",
    url = "https://github.com/bazelbuild/rules_go/releases/download/0.9.0/rules_go-0.9.0.tar.gz",
    sha256 = "4d8d6244320dd751590f9100cf39fd7a4b75cd901e1f3ffdfd6f048328883695",
)

http_archive(
    name = "com_github_bazelbuild_buildtools",
    url = "https://github.com/bazelbuild/buildtools/archive/master.zip",
    strip_prefix = "buildtools-master",
)

new_http_archive(
    name = "gomemcache",
    build_file = "BUILD.gomemcache",
    url = "https://github.com/bradfitz/gomemcache/archive/master.zip",
    strip_prefix = "gomemcache-master",
)


#git_repository(
#  name = "com_google_absl",
#  remote = "https://github.com/abseil/abseil-cpp.git",
#  commit = "52a2458965fc2ef6f03fb692b253a1ca56ff6e39",
#)

load("@io_bazel_rules_go//go:def.bzl", "go_rules_dependencies", "go_register_toolchains")

go_rules_dependencies()
go_register_toolchains()

