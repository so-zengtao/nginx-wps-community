#!/usr/bin/env ruby
require 'cgi'
require './include/parts.rb'
require './include/funcs.rb'
require 'yaml'
#lang_redirect 'zh', 'http://community.wps.cn/download/#alpha'

def html_version_item f
  cont = ""
  y = YAML.load_file(f)
  cont += "<h2>#{y["full_name"]}</h2>"
  cont += "<div class=\"ver_item\">"
  if y["whats_new"]
    cont += "<h3>What's new: </h3>"
    cont += "<ol>"
    cont += y["whats_new"].lines.collect {|l| "<li>#{l.chomp}</li>"}.join "\n"
    cont += "</ol>"
  end
  if y["release_notes"]
    cont += "<h3>Notes: </h3>"
    cont += "<ul>"
    cont += y["release_notes"].lines.collect {|l| "<li>#{l.chomp}</li>"}.join "\n"
    cont += "</ul>"
  end
  if y["addresses"]
    cont += "<h3>Addresses: </h3>"
    y["addresses"].each do |ver|
      address = ver["address"]
      filename = address.rpartition("/")[2]
      sha1 = ver["sha1sum"]
      cont += "<p class=\"dl_addr\">
        <a href=\"#{address}\" onclick=\"onDownload(this)\" data-filename=\"#{filename}\">#{filename}</a>
        <br/>SHA1: #{sha1}
        </p>"
    end
  end
  cont += "</div>"
  return cont
end
if not $root2
  $root2 = ".."
end
def html_versions
  files = Dir.glob($root2 + "/data/versions/**/*.yaml").sort{|a,b| -(File.basename(a).to_i <=> File.basename(b).to_i) }
  files.collect do |f|
    html_version_item f
  end.join "\n"
end

cont = <<EOF
#{html_header "Downloads"}
<script type="text/javascript">
  function onDownload(n)
  {
    url = "/bin/st.rb?t=download&amp;a=" + n.getAttribute("data-filename") + "&amp;r=" + Math.random();
    a = new XMLHttpRequest();
    a.open("GET", url , false);
    a.send();
  }
</script>
<div class="body">
<h1>Product Download</h1>
#{html_versions}
</div>
<h1>Language Package Downloads</h1>
#{html_tail}
EOF
cgi = CGI.new
cgi.out {
  cont
}
