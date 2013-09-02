#!/usr/bin/env ruby

require 'cgi'
require '../include/parts.rb'

def html_sub_dir
  cont = ""
  x = Dir.entries(".").each.to_a.sort do |a, b| a.to_s <=> b.to_s end
  x.collect do |a|
    if (a != '.' && a != '..' && a!= 'index.rb')
     cont += "<tr><td class=\"n\"><a href=\"#{a}\">#{a}</a></td> <td class=\"t\">Directory</td></tr>"
    end
  end
  return cont
end


cont = <<EOF
#{html_header "Development"}
<h1>\><a href="..">HomePage</a> \> <a href=".">download</a></h1>
<div class="list">
<table summary="Directory Listing" cellpadding="0" cellspacing="10" width="600">
<thead><tr><td class="n" style=\"font-size:18px;\"><b>Name</b></td><td class="t" style=\"font-size:16px;\"><b>Type</b></td></tr></thead>
<tbody>
#{html_sub_dir}
</tbody>
</table>
</div>

#{html_tail}
EOF

cgi = CGI.new
cgi.out {
  cont
}

