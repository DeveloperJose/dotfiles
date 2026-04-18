function gdd
  git -c diff.external=difft diff $argv
end