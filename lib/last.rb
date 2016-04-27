# all work related to finding the last episode

def last_ep(show)
  last_ep = '0;0'
  @eps[show].keys.each do |season|
    @eps[show][season].keys.each do |episode|
      last_ep = "#{season};#{episode}"
    end
  end
  
  return last_ep.split(';')
end

def last_from_thetvdb(show)
  thetvdb_episodes = thetvdb_lookup(show)
  
  last_season, last_episode = last_ep(show)
  
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
        if @eps.has_key? show 
          if @eps[show].has_key?(season.to_i)
            if @eps[show][season.to_i].has_key?(episode.to_i)
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
# can decide what to do later or which API to use to see if 
# a new one is available
def look_for_last
  
  episodes_last = {}
  @eps.keys.each do |show|
    last_from_thetvdb(show)
    #@eps[show].keys.each do |season|
    #  @eps[show][season].keys.each do |episode|
    #    episodes_last[show] = show_index(season, episode)
    #  end
    #end
  end
  
end