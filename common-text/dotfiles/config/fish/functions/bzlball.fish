function bzlball --wraps bazel
  ~/sbp/tools/bazelisk build ...:all $argv
end
