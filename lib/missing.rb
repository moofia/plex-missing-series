# missing episodes

def missing_print (show, pair)
  if $opts["torrentsonly"]
    data = URI.escape(show+" "+pair)
    puts "http://thepiratebay.se/search/#{data}/0/7/200"
  elsif $opts["torrents"]
    data = URI.escape(show+" "+pair)
    puts "show --> #{show} #{pair} [ URL: http://thepiratebay.se/search/#{data}/0/7/200 ]"
  else
    puts "show --> #{show} #{pair} !!MISSING!!"
  end
end

def missing_process (show, pair)
  missing_print show, pair
end

# check if we have the previous episode
def missing_episode_check_previous ( episodes, show, season, episode)

  missing = {}

  for i in (episode - 1).downto(1)
    if not episodes[show][season][i]
      missing_index = show_index season, i
      missing[i] = "#{show};#{missing_index}"
    else 
      break
    end
  end

  missing.keys.sort.each do |i| 
    if not missing[1]
      missing_process missing[i].split(';')[0] , missing[i].split(';')[1]
    end
  end

end

def missing(episodes)
  episodes.keys.each do |show|
    episodes[show].keys.each do |season|
      episodes[show][season].keys.each do |episode|
        missing_episode_check_previous episodes, show, season, episode
      end
    end
  end
end
