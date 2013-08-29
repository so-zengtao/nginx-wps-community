#!/usr/bin/env ruby

puts "Content-Type: text/plain"
puts 

ENV.each do |k, v|
  puts "#{k} = #{v}"
end
