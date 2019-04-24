function bzltall --wraps bazel
  bazel test ...:all $argv
end
