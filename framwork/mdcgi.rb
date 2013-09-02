#!/usr/bin/env ruby
require 'cgi'

$cgi = CGI.new
$mdfile = ENV['DOCUMENT_ROOT'] + ENV['DOCUMENT_URI']

require '../root/include/parts.rb'

begin
  cont = `markdown "#{$mdfile}" 2>&1`
  $cgi.out do
    html_header(ENV["DOCUMENT_URI"]) + 
        "<div class='markdown'>" + cont + "</div>" +
        html_tail
  end
rescue
  puts "Content-type: text/plain; charset=utf-8"
  puts "Status: 500 Internal Server Error"
  puts
  puts e.message
  e.backtrace.each do |x|
    puts x
  end
end


