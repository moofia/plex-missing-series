# place for common methods

# generic logger
def log(msg,level=nil)
 level ||= 1 # not needed
 puts "#{@script} -> #{msg}"
end

def log_debug(msg)
  if $opts['debug']
    log "DEBUG #{msg}"
  end
end

def read_config
  log_debug "read_config"
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
      ["--debug", Getopt::BOOLEAN],
      ["--help",  Getopt::BOOLEAN],
      ["--show",  Getopt::OPTIONAL],
      )
  rescue Getopt::Long::Error => e
    puts "#{@script} -> error #{e.message}"  
    puts 
    help
  end
end

def help

  puts <<-EOF
#{@script} [OPTIONS]

  --help            help
  --debug           debugging enable
  --show            show we interested in
  
  
EOF
  exit
end

# if debugging is turned on puts
def puts_debug(msg)
  if $opts["debug"]
    puts "#{@script} -> DEBUG: #{msg}"
  end
end

def debug(what)
  puts "#{@script} -> debug and exit..\n"
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