function bzltall --wraps bazel
  ~/sbp/tools/bazelisk test ...:all $argv
end
