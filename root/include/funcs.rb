def lang_redirect lang, dest
  if $cgi['lang'] == lang
    $cgi.out('status' => '302', 'location' => dest) {''}
    exit 0
  end
end
