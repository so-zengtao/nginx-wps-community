require 'cgi'
require 'include/parts.rb'
require 'yaml'

def html_gallery_item item
  name = item['Name'];
  img_priview = "/images/gallery/" + name + ".priview.png"
  img = "/images/gallery/" + name + ".png"
  if not File.exists? $root + img_priview
    path = $root + "/images/gallery"
    `convert -sample 200x160 #{path}/#{name}.png #{path}/#{name}.priview.png`
  end
<<EOF
<div class="gallery_item">
  <a href="#{img}"><img src="#{img_priview}"/></a><br/>
  #{item['Description']}
</div>
EOF
end

def html_gallery
  gallery = YAML.load_file $root2 + "/data/gallery/gallery.yaml"
  gallery.collect do |item|
    x = item["Content"].collect do |item2| html_gallery_item item2 end.join
    "<div class=\"gallery_group\"><h2>#{item["Title"]}</h2>\n" + x + 
      "<div class=\"clear_both\"></div></div>"
  end.join "\n"
end

cont = <<EOF
#{html_header "Gallery"}
<div class="body">
<h1>Gallery</h1>
#{html_gallery}
</div>
Has any interest about our pruduct?<br/>
Try it now: <a href="/download.html">Download</a>.
<br/>
#{html_tail}
EOF

$cgi.out {
  cont
}
