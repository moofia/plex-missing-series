# all work related to finding the last episode from thetvdb

def thetvdb_last_ep(episodes,show)
  log_debug
  last_ep = '0;0'
  episodes[show].keys.each do |season|
    episodes[show][season].keys.each do |episode|
      last_ep = "#{season};#{episode}"
    end
  end
  
  return last_ep.split(';')
end

def thetvdb_first_ep(episodes,show)
  log_debug
  first_ep = '0;0'
  episodes[show].keys.each do |season|
    episodes[show][season].keys.each do |episode|
      if first_ep == '0;0'
        first_ep = "#{season};#{episode}"
      end
    end
  end
    
  return first_ep.split(';')
end

def thetvdb_last_process(episodes,episodes_missing,show)
  log_debug
  thetvdb_episodes = thetvdb_find(show)
  season_last, episode_last = thetvdb_last_ep(episodes,show)
  season_first, episode_first = thetvdb_first_ep(episodes,show)
  
  thetvdb_episodes.keys.each do |show|
    thetvdb_episodes[show]['episodes'].keys.each do |season|
      next if season == "0"
      thetvdb_episodes[show]['episodes'][season].keys.each do |episode|
        first_aired = thetvdb_episodes[show]['episodes'][season][episode]['first_aired']
        show_index = show_index(season, episode)
        
        plex_has = false
        missing  = true
        
      
        # remove shows that we have
        if episodes.has_key? show 
          if episodes[show].has_key?(season.to_i)
            if episodes[show][season.to_i].has_key?(episode.to_i)
              plex_has = true              
            end
          end
        end
      
        # for now we are only interested in episodes greater than our first one and 
        # inclusive of the whole season
        if season.to_i < season_first.to_i 
          missing = false
        end
        
        missing = false if plex_has
        
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
def thetvdb_missing_src_thetvdb(episodes,episodes_missing)  
  log_debug
  episodes.keys.each do |show|
    thetvdb_last_process(episodes,episodes_missing,show)
  end
end