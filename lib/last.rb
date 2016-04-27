# all work related to finding the last episode

def last_ep(episodes,show)
  last_ep = '0;0'
  episodes[show].keys.each do |season|
    episodes[show][season].keys.each do |episode|
      last_ep = "#{season};#{episode}"
    end
  end
  
  return last_ep.split(';')
end

def last_from_thetvdb(episodes,show)
  thetvdb_episodes = thetvdb_lookup(show)
  
  last_season, last_episode = last_ep(episodes,show)
  
  thetvdb_episodes.keys.each do |show|
    thetvdb_episodes[show].keys.each do |season|
      next if season == "0"
      thetvdb_episodes[show][season].keys.each do |episode|
        #puts "#{show} #{season} #{episode}"
        first_aired = thetvdb_episodes[show][season][episode]['first_aired']
        show_index = show_index(season, episode)
        
        plex_has = false
        missing = false
        
        # remove shows that we have
        if episodes.has_key? show 
          if episodes[show].has_key?(season.to_i)
            if episodes[show][season.to_i].has_key?(episode.to_i)
              plex_has = true              
            end
          end
        end
        
        # curerntly only look for episodes greater than the last one we have
        #puts "#{season} #{episode} vs #{last_season} #{last_episode} "

        if season.to_i > last_season.to_i
          missing = true
        end
        
        if season.to_i == last_season.to_i and episode.to_i > last_episode.to_i
          missing = true
        end
        
        missing = false if plex_has
        
        if first_aired =~ /\w/
          date_available = Date.today+1
          date_aired     = Date.parse first_aired
          if ( date_available > date_aired ) and missing
            puts "show --> #{show} #{show_index} !!MISSING!! aired: #{first_aired}"
            
          end
        end
      end
    end
  end
end

# looks for the last episode
def look_for_last(episodes)  
  episodes.keys.each do |show|
    last_from_thetvdb(episodes,show)
  end
end