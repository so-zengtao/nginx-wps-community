#!/usr/bin/env ruby
require 'cgi'
require './include/parts.rb'
require 'yaml'

cont = <<EOF
#{html_header "About us"}
<div class="body">
todo...
</div>
#{html_tail}
EOF
cgi = CGI.new
cgi.out {
  cont
}
