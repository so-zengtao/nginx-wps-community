#!/usr/bin/env ruby

puts "Content-Type: text/plain"
puts 

s = `git rev-parse HEAD`

gitlog = `git pull --rebase 2>&1`
puts gitlog

gitret = "git pull return: #{$?}"
puts gitret

e = `git rev-parse HEAD`

if s == e
  puts "No file updated."
elsif File.exists? $root + "/forum/cache"
  puts `rm #{$root + "/forum/cache/*.php"} -v`
end

if not $root2
  $root2 = "../.."
end
log = open($root2 + "/log/update.log", "a")
log.puts Time.now
log.puts "Call from #{ENV["REMOTE_ADDR"]}"
log.puts gitlog
log.puts gitret
log.puts 
log.close

