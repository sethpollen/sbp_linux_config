function grepr --description "Grep in all files under the current directory" \
    --wraps=grep
  grep -r $argv
end
