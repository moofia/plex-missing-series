# missing episodes

# keeps track of what episodes we have
def missing_episodes_track ( episodes_missing, show, season, episode,extra=nil)
  episodes_missing[show]                  = {} if episodes_missing[show].class.to_s != 'Hash'
  episodes_missing[show][season]          = {} if episodes_missing[show][season].class.to_s != 'Hash'
  episodes_missing[show][season][episode] = 'missing do something'
end

def missing_url(show,pair)
  data = URI.escape(show + ' ' + pair)
  if $opts['kat']
    url = "https://kat.cr/usearch/#{data}%20category%3Atv/?field=seeders&sorder=desc"
  else
    url = "http://thepiratebay.se/search/#{data}/0/7/200"
  end
  return url
end

def missing_display (show, pair,extra=nil)
  extra ||= '' # there are times when we need to display extra information
  
  if $opts['urls']
    extra = extra + ' ' + missing_url(show, pair)
  end
  
  if $opts['urls_only']
    puts missing_url(show, pair)
  elsif $opts['urls_only_osx']
    puts "open -a safari \"#{missing_url(show, pair)}\""
  else
    puts "show --> #{show} #{pair} !!MISSING!! #{extra}"
  end
end

def missing_process (episodes_missing, show,  pair,extra=nil)
  extra ||= '' # there are times when we need to display extra information
  if $opts['html']
    season, episode = show_unindex(pair)
    missing_episodes_track episodes_missing, show, season, episode, extra      
  else 
    missing_display show, pair, extra
  end
end

# check if we have the previous episode
# TODO: name of method is dubious
def missing_episode_check_previous ( episodes, episodes_missing, show, season, episode)

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
      show = missing[i].split(';')[0] 
      pair = missing[i].split(';')[1]
      missing_process episodes_missing, show , pair
    end
  end

end

def missing(episodes, episodes_missing)
  episodes.keys.each do |show|
    episodes[show].keys.each do |season|
      episodes[show][season].keys.each do |episode|
        missing_episode_check_previous episodes, episodes_missing, show, season, episode
      end
    end
  end
end

