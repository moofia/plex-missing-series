# all work related to finding the last episode from thetvdb

# plex last episode of a show
def thetvdb_missing_plex_last_ep(episodes_plex,show)
  log_debug
  last_ep = '0;0'
  episodes_plex[show].keys.each do |season|
    episodes_plex[show][season].keys.each do |episode|
      last_ep = "#{season};#{episode}"
    end
  end
  
  return last_ep.split(';')
end

# plex first episode of a show
def thetvdb_missing_plex_first_ep(episodes_plex,show)
  log_debug
  first_ep = '0;0'
  episodes_plex[show].keys.each do |season|
    episodes_plex[show][season].keys.each do |episode|
      if first_ep == '0;0'
        first_ep = "#{season};#{episode}"
      end
    end
  end
    
  return first_ep.split(';')
end

# remove episodes that are found in plex
def thetvdb_missing_plex_found(episodes_plex, show,season,episode)
  plex_has = false
  
  # remove shows that we have
  if episodes_plex.has_key? show 
    if episodes_plex[show].has_key?(season.to_i)
      if episodes_plex[show][season.to_i].has_key?(episode.to_i)
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
def thetvdb_missing_last_process(episodes_plex,episodes_missing,show)
  log_debug
  thetvdb_episodes            = thetvdb_get(show)
  season_last, episode_last   = thetvdb_missing_plex_last_ep(episodes_plex,show)
  season_first, episode_first = thetvdb_missing_plex_first_ep(episodes_plex,show)
  
  thetvdb_episodes.keys.each do |show|
    thetvdb_episodes[show]['episodes'].keys.each do |season|
      next if season == "0"
      thetvdb_episodes[show]['episodes'][season].keys.each do |episode|
        first_aired = thetvdb_episodes[show]['episodes'][season][episode]['first_aired']
        show_index  = show_index(season, episode)
        plex_has    = false
        missing     = true

        plex_has    = thetvdb_missing_plex_found(episodes_plex,show,season,episode)
        missing     = thetvdb_missing_range(season, season_first, episode, episode_first)

        missing     = false if plex_has
                
        if first_aired =~ /\w/
          date_available = Date.today
          date_aired     = Date.parse first_aired
          if ( date_available > (date_aired + 1) ) and missing
            missing_process episodes_missing, show, show_index,"aired: #{first_aired}"
          end
        end
      end
    end
  end
end

# use the thetvdb
def thetvdb_missing(episodes_plex,episodes_missing)  
  log_debug
  episodes_plex.keys.each do |show|
    thetvdb_missing_last_process(episodes_plex,episodes_missing,show)
  end
end