# place for common methods

# if debugging is turned on puts
def puts_debug(msg)
  if $opts["debug"]
    puts "#{@script} --> DEBUG: #{msg}"
  end
end

def debug(what)
  puts "#{@script} --> debug and exit..\n"
  ap what
  exit
end

# XXX: terrible name!
# what do you s01e01 ? the season episode combo?
def show_index(season, episode)

  if ( episode < 10 ) 
    episode = "0#{episode}"
  end
  if ( season < 10 ) 
    season = "0#{season}"
  end

  show_index = "s#{season}e#{episode}"
  return show_index

end