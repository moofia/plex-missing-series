# all work related to finding the last episode

# looks for the last episode
# can decide what to do later or which API to use to see if 
# a new one is available
def look_for_last
  
  episodes_last = {}
  @eps.keys.each do |show|
    @eps[show].keys.each do |season|
      @eps[show][season].keys.each do |episode|
        episodes_last[show] = show_index(season, episode)
      end
    end
  end
  debug episodes_last
end