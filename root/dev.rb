#!/usr/bin/env ruby
require 'cgi'
require './include/parts.rb'


if not $root2
  $root2 = ".."
end
def html_mui_progress
  fpath = $root2 + "/var/wps_mui.st"
  if not File.exists? fpath
    return
  end
  cont = ""
  sts = []
  open(fpath) do |fd|
    fd.each_line do |line|
      line.chomp!
      c = /(\w+)\s*(\d+)\s*\/\s*(\d+)/.match line
      sts += [ [line, c[2], c[3], c[2].to_f / c[3].to_f] ]
    end
  end
  sts.sort! {|x, y| -(x[3] <=> y[3])}
  sts.each do |c|
    cont += "<div style='background: gray; position:relative; height: 1.2em; margin-bottom: 1px;'>
    <div style='background: green; width: #{c[3] * 100}%; height: 100%; position: absolute; top: 0;'></div>
    <div style='position: absolute; font-family: Monospace; color: white; margin: 2px 2px;'>#{c[0]}</div>
    </div>"
  end
  return cont
end

cont = <<EOF
#{html_header "Development"}
<div class="body">
<h1>Develop for KSO/WPS</h1>
  <h2>Translate KSO/WPS</h2>
    Project Address: <a href="https://github.com/wps-community/wps_i18n" target="_blank">https://github.com/wps-community/wps_i18n</a>
    <br/>#{html_mui_progress}
    <b>Note: </b>We will adjust some framework about internationalization for KSO/WPS in alpha 12.
    So some of the translation items will be lost in alpha 12(about 10-30%). 
    Beta 2 will be released base on alpha 11, and beta 2 will be maintained for a long time.
    If you feel worried about it, you can just wait for alpha 12. 
  <h2>Qt modified by KSO/WPS</h2>
    Project Address: <a href="https://gitcafe.com/wpsv9/qt-kso-integration" target="_blank">https://gitcafe.com/wpsv9/qt-kso-integration</a>
  <h2>Source of WPS Community Website</h2>
    Project Address: <a href="https://github.com/wps-community/wps_community_website" target="_blank">https://github.com/wps-community/wps_community_website</a>
</div>
<br/>
#{html_tail}
EOF
cgi = CGI.new
cgi.out {
  cont
}
