#!/usr/bin/env ruby

puts "Content-Type: text/plain"
puts 

if not $root2
  $root2 = "../.."
end

$repo_path = $root2 + "/var/wps_mui"

if not File.exists? $repo_path
  puts `git clone git://github.com/wps-community/wps_i18n.git #{$repo_path} 2>&1`
else
  puts `cd #{$repo_path}; git pull 2>&1`
end

Dir.chdir $repo_path


langs = Dir.glob("*/lang.conf").collect {|x| x.sub "/lang.conf", ""}
langs -= ["sample", "en_US"]
langs.sort! 

File.open("../wps_mui.st", "w") do |fd|
  langs.each do |lang|
    total = `cat #{lang}/ts/*.ts | grep -v "<translation.*obsolete.*>" | grep "<translation.*>" -c`.to_i
    untrans = `cat #{lang}/ts/*.ts | grep -v "<translation.*obsolete.*>" | grep "></translation>" -c`.to_i
    puts "#{lang} #{total - untrans} / #{total}"
    fd.puts "#{lang} #{total - untrans} / #{total}"
  end
end

puts "OK"


