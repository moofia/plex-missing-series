# all work related to finding the last episode from thetvdb

class TheTvDbMissing
  
  def initialize
  end
  
# plex last episode of a show
def thetvdb_missing_plex_last_ep(show)
  log_debug
  last_ep = '0;0'
  $plex.episodes[show].keys.each do |season|
    $plex.episodes[show][season].keys.each do |episode|
      last_ep = "#{season};#{episode}"
    end
  end
  
  return last_ep.split(';')
end

# plex first episode of a show
def thetvdb_missing_plex_first_ep(show)
  log_debug
  first_ep = '0;0'
  
  $plex.episodes[show].keys.each do |season|
    $plex.episodes[show][season].keys.each do |episode|
      if first_ep == '0;0'        
        first_ep = "#{season};#{episode}"
      end
    end
  end
    
  return first_ep.split(';')
end

# remove episodes that are found in plex
def thetvdb_missing_plex_found(show,season,episode)
  plex_has = false
  
  # remove shows that we have
  if $plex.episodes.has_key? show 
    if $plex.episodes[show].has_key?(season.to_i)
      if $plex.episodes[show][season.to_i].has_key?(episode.to_i)
        plex_has = true              
      end
    end
  end
  plex_has
end

# handle the range of where we loop up to for episodes
def thetvdb_missing_range(season, season_first, episode, episode_first)
  missing = true
  
  # for now we are only interested in episodes greater than our first one and 
  # inclusive of the whole season
  if season.to_i < season_first.to_i 
    missing = false
  end
  
  if $config["missing"]["start_at_first_found"]
    if episode_first.to_i > episode.to_i 
      missing = false            
    end
  end
  
  missing
end

# loop through all the episodes found in thetvdb for a show
# remove those that exists in plex
# ignore specials for now
# TODO: terrible method name
def thetvdb_missing_last_process(show)
  log_debug
  
  $thetvdb.show(show)

  season_last,  episode_last  = thetvdb_missing_plex_last_ep(show)
  season_first, episode_first = thetvdb_missing_plex_first_ep(show)
  log_debug("#{show} start s#{season_first}e#{episode_first} : last s#{season_last}e#{episode_last}")

  if $thetvdb.episodes.has_key?(show)
    $thetvdb.episodes[show]['episodes'].keys.each do |season|
      next if season == "0"
      
      $thetvdb.episodes[show]['episodes'][season].keys.each do |episode|
        first_aired = $thetvdb.episodes[show]['episodes'][season][episode]['first_aired']
        show_index  = show_index(season, episode)
        plex_has    = thetvdb_missing_plex_found(show,season,episode)
        missing     = thetvdb_missing_range(season, season_first, episode, episode_first)
        missing     = false if plex_has
                
        if first_aired =~ /\w/
          date_available = Date.today
          date_aired     = Date.parse first_aired
          if ( date_available > (date_aired + 1) ) and missing
            missing_process show, show_index,"aired: #{first_aired}"
          end
        end
      end
    end
  end
end

# use the thetvdb
def process  
  log_debug
  $plex.episodes.keys.each do |show|
    thetvdb_missing_last_process(show)
  end
end

end