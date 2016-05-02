# place for common methods

# generic logger
def log(msg,level=nil)
 level ||= 1 # not needed
 puts "#{@script} -> #{msg}"
end

def log_debug(msg=nil)
  if $opts['debug']
    
    label  = caller_locations(1,1)[0].label
    lineno = caller_locations(1,1)[0].lineno
    path   = File.basename caller_locations(1,1)[0].path
    
    log "DEBUG: [#{path}:#{lineno} #{label}] #{msg}"
    
  end
end

def parse_config
  log_debug
  begin
    $config = YAML::load(File.read("#{$script_dir}/etc/config.defaults.yaml"))
  rescue => e
    puts "#{@script} -> yaml error #{e.message}"  
    exit 2
  end
end

def get_opts
  # options 
  begin
    $opts = Getopt::Long.getopts(
      ["--debug",        Getopt::BOOLEAN],
      ["--help",         Getopt::BOOLEAN],
      ["--show",         Getopt::OPTIONAL],
      ["--thetvdb",      Getopt::BOOLEAN],
      ["--urls",         Getopt::BOOLEAN],
      ["--urls_only",    Getopt::BOOLEAN],
      ["--kat",          Getopt::BOOLEAN],
      ["--cache",        Getopt::BOOLEAN],
      )
  rescue Getopt::Long::Error => e
    puts "#{@script} -> error #{e.message}"  
    puts 
    help
  end
  
  help if $opts["help"]
end

def help

  puts <<-EOF
#{@script} [OPTIONS]

  --help            help.
  --debug           debugging enable.
  --show            request a single show.
  --urls            include URLS in the output of missing episodes.
  --urls_only       list only the URLS for the missing episodes found.
  --kat             provide KickAss Torrents Links instead of the default Pirate Bay Links.
  --thetvdb         use TheTVDB for missing episodes.
  --cache           mostly used in debugging, uses cache only data
  
  
EOF
  exit
end

def debug(what)
  puts "#{@script} -> debug and exit..\n"
  ap what.class
  ap what
  exit
end

# XXX: terrible name!
# what do you s01e01 ? the season episode combo?
def show_index(season, episode)

  if ( episode.to_i < 10 ) 
    episode = "0#{episode}"
  end
  if ( season.to_i < 10 ) 
    season = "0#{season}"
  end

  show_index = "s#{season}e#{episode}"
  return show_index

end
