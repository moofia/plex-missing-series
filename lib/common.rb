# place for common methods

# generic logger
def log(msg) 
 puts "#{File.basename $0} -> #{msg}"
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
  $config = {}
  $config['script_dir'] = File.dirname(__FILE__).gsub(/\/lib$/, '')
  
  begin
    yaml = YAML::load(File.read("#{$config['script_dir']}/etc/config.defaults.yaml"))
    $config.merge!(yaml)
  rescue => e
    puts "#{File.basename $0} -> yaml error #{e.message}"  
    exit 2
  end
  
  if File.exists?("#{$config['script_dir']}/etc/config.yaml")
    begin
      conf_local = YAML::load(File.read("#{$config['script_dir']}/etc/config.yaml"))
    rescue => e
      puts "#{File.basename $0}} -> yaml error #{e.message}"  
      exit 2
    end
    $config.merge!(conf_local)
  end

end

def get_opts
  # options 
  begin
    $opts = Getopt::Long.getopts(
      ["--debug",         Getopt::BOOLEAN],
      ["--help",          Getopt::BOOLEAN],
      ["--show",          Getopt::OPTIONAL],
      ["--thetvdb",       Getopt::BOOLEAN],
      ["--urls",          Getopt::BOOLEAN],
      ["--urls_only",     Getopt::BOOLEAN],
      ["--urls_only_osx", Getopt::BOOLEAN],
      ["--cache",         Getopt::BOOLEAN],
      ["--html",          Getopt::BOOLEAN],
      )
  rescue Getopt::Long::Error => e
    puts "#{File.basename $0}} -> error #{e.message}"  
    puts 
    help
  end
  
  help if $opts["help"]
end

def help

  puts <<-EOF
#{File.basename $0}} [OPTIONS]

  --help            help.
  --debug           debugging enable.
  --show            request a single show.
  --urls            include URLS in the output of missing episodes.
  --urls_only       list only the URLS for the missing episodes found.
  --urls_only_osx   list only the URLS for the missing episodes found and include the output in a launchable manner.
                      eg: open -a safari "<link to url>"
  --kat             provide KickAss Torrents Links instead of the default Pirate Bay Links.
  --thetvdb         use TheTVDB for missing episodes.
  --cache           mostly used in debugging, uses cache only data
  --html            saves all output in an html file [currently a single file]
  
  
EOF
  exit
end

def debug(what)
  puts "#{File.basename $0}} -> debug and exit..\n"
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

# bad name once again
def show_unindex(pair)
  a,season, b, episode = pair.split(/(\d+)/)
  season.gsub!(/^0/,'')
  episode.gsub!(/^0/,'')
  return [season, episode]
end

def show_pretty(show, season, episode)
  display = "#{show} #{show_index season, episode}"
  return display
end
