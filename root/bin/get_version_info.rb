#!/usr/bin/env ruby1.9.3
require 'cgi'
require 'yaml'
require 'json'

puts "Content-Type: text/plain"
puts

if not $root2
  $root2 = "../.."
end
$d = $root2 + "/data/versions"

#def get_last_version
#  x = Dir.new($d).each.to_a.sort do |a,b| a.to_i <=> b.to_i end
#  return x.last.to_i
#end

def get_last_version
  files = Dir.glob($d + "/**/*.yaml").sort do |a,b| -(File.basename(a).to_i <=> File.basename(b).to_i) end
#  files.each do |a| puts File.basename(a) end
  return File.basename(files.first).to_i
end

#def get_address v
#  y = YAML.load_file($d + "/" + v + ".yaml")
#  y['addresses'].collect do |t|
#    t['type'] + " " + t['sha1sum'] + " " + t['address']
#  end.join "\n" 
#end

def get_address v
  if(File.exist?($d + "/beta/" + v + ".yaml" ))
    y = YAML.load_file($d + "/beta/" + v + ".yaml")
  else
    y = YAML.load_file($d + "/alpha/" + v + ".yaml")
  end
  y['addresses'].collect do |t|
    t['type'] + " " + t['sha1sum'] + " " + t['address']
  end.join "\n"
end

#def get_info v
#  y = YAML.load_file($d + "/" + v + ".yaml")
#  return JSON.generate y
#end
def get_info v
  if(File.exist?($d + "/beta/" + v + ".yaml" ))
    y = YAML.load_file($d + "/beta/" + v + ".yaml")
  else
    y = YAML.load_file($d + "/alpha/" + v + ".yaml")
  end
 # return JSON.generate y
end

$dir = $d + "/alpha"

def get_versions
  files = Dir.glob($d + "/**/*.yaml").sort do |a,b| -(File.basename(a).to_i <=> File.basename(b).to_i) end 
  files.collect do |a|
    if File.basename(a) =~ /[0-9]+\.yaml/
      File.basename(a).to_i.to_s
    else
      nil
    end
  end.select {|a| a}.join "\n"
end



#def get_versions
#  x = Dir.new($dir).each.to_a.sort do |a,b| - a.to_i <=> b.to_i end
#  x.collect do |a|
#    if a =~ /[0-9]+\.yaml/
#      a.to_i.to_s
#    else
#      nil
#    end
#  end.select {|a| a}.join "\n"
#end

def help
  "Usage: \n" + 
  "Get Last Version: get_version_info.rb?c=get_last_version\n" + 
  "Get All Versions: get_version_info.rb?c=get_versions\n" + 
  "Get Last Version Download Address: get_version_info.rb?c=get_address\n" +
  "Get Special Version Download Address: get_version_info.rb?c=get_address&v=4096\n" +
  "Get Last Version Info: get_version_info.rb?c=get_info\n" +
  "Get Special Version Info: get_version_info.rb?c=get_info&v=4096\n"
end
cgi = CGI.new
cmd = cgi['c']

if cmd == "get_last_version"
  puts get_last_version
elsif cmd == "get_versions"
  puts get_versions
elsif cmd == "get_address"
  v = cgi['v'] != "" ? cgi['v'] : get_last_version
  puts get_address(v.to_s)
elsif cmd == "get_info"
  v = cgi['v'] != "" ? cgi['v'] : get_last_version
  puts get_info(v.to_s)
else
  puts help
end
