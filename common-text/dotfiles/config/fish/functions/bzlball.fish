function bzlball --wraps bazel
  bazel build ...:all $argv
end
