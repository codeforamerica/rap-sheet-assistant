%w(
  .ruby-version
  .rbenv-vars
  tmp/restart.txt
  tmp/caching-dev.txt
  parser/lib/grammars
).each { |path| Spring.watch(path) }
