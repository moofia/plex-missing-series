# home of everything html output related

def html_header
end

def html_footer
end

def html_row(text, kat, bay)
  html = <<-HTML 
  #{text} | <a target=\"blank\" href=\"#{kat}\">kat</a> | <a target=\"blank\" href=\"#{bay}\">bay</a> <br>
  HTML
  puts html
end

# takes a Hash of HASH[SHOW][SEASON][EPISODE]
def html_content(episodes_missing)
  episodes_missing.keys.each do |show|
    episodes_missing[show].keys.each do |season|
      episodes_missing[show][season].keys.each do |episode|
        pair = show_index season, episode
        data = URI.escape(show + ' ' + pair)
        kat  = "https://kat.cr/usearch/%22#{data}%20category%3Atv/?field=seeders&sorder=desc"
        bay  = "http://thepiratebay.se/search/#{data}/0/7/200"
        html_row("#{show} #{pair}" , kat, bay)
      end
    end
  end
end

def html_create(episodes_missing)
  html_header
  html_content episodes_missing
  html_footer
end