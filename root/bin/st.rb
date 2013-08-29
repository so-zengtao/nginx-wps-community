open($root2 + "/log/statistics.log", "a") do |f|
  f.puts Time.now.strftime("%F %T %z") + " " + $cgi["t"] + " " + $cgi["a"]
end

puts "OK"

