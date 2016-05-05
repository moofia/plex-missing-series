# home of everything html output related

def html_header
  puts 'header'
end

def html_footer
  puts 'footer'
end

# takes a Hash of HASH[SHOW][SEASON][EPISODE]
def html_content(episodes_missing)
  ap episodes_missing
end

def html_create(episodes_missing)
  html_header
  html_content episodes_missing
  html_footer
end