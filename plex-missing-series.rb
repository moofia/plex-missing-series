#! /usr/bin/env ruby


require 'sqlite3'
require 'getopt/long'
require 'awesome_print'

# exit on ctrl-c
trap("INT") do
  puts
  exit 2
end 

@script = File.basename $0 

@eps                     = {} # shit name must change
$opts                    = {}
$opts["debug"]           = 0
$opts["season_complete"] = 0  # not used yet

def help

  puts <<-EOF
#{@script} [OPTIONS]

  --help            help
  --debug           debugging enable
  --show            show we interested in
  
  
EOF
  exit
end

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

help if $opts["help"]

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

# keeps track of what episodes we have
def episodes_track ( show, season, episode, name)
  @eps[show]                 = {} if @eps[show].class.to_s != 'Hash'
  @eps[show][season]         = {} if @eps[show][season].class.to_s != 'Hash'
  @eps[show][season][episode] = name
end

def find_db
  file_name = 'com.plexapp.plugins.library.db'
  # for dev it looks in current directory first
  # can add locations as we find them. only the first match is used
  paths     = [ '.',
                '/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-in Support/Databases',
                "#{ENV['HOME']}/Library/Application Support/Plex Media Server/Plug-in Support/Databases"
               ]
  db        = ''
  
  paths.each do |path|
    if File.directory? path
      if File.exists? "#{path}/#{file_name}"
        # first match is used
        if db == ''
          db = "#{path}/#{file_name}"
        end
      end
    end
  end
  
  if db !~ /\w/
    puts "error : could not find db file \"#{file_name}\" "
    exit 2
  end
  
  puts_debug "find_db using \"#{db}\""
  return db
end

# very basic db setup
# should test / rescue sqlite3
def db_setup
  
  db_file = find_db
  db_tmp = '/tmp/plex_missing_tmp.db'
  
  # cp to tmp as the db is locked if being used
  `cp "#{db_file}" #{db_tmp}`

  # not too sure why but i was having a problem where a 0 byte file was cp'd
  # def a local issue i assume but the check was needed
  if test ?s, db_tmp
    db = SQLite3::Database.new db_tmp
  else 
    puts "error-> can not open #{db_tmp} for reasing"
    exit 2
  end
  return db
end

def missing_print (show, pair)
  puts "show --> #{show} #{pair} !!MISSING!!"
end

def missing_process (show, pair)
  missing_print show, pair
end

# check if we have the previous episode
def episode_check_previous ( show, season, episode)

  missing = {}

  for i in (episode - 1).downto(1)
    if not @eps[show][season][i]
      missing_index = show_index season, i
      missing[i] = "#{show};#{missing_index}"
    else 
      break
    end
  end

  missing.keys.sort.each do |i| 
    if not missing[1]
      missing_process missing[i].split(';')[0] , missing[i].split(';')[1]
    end
  end

end

# print the shows that are found only in debug mode
def show_print_debug ( show, season, episode, name)
  if $opts["debug"]
    show_index = show_index season, episode
    puts "show --> #{show} #{show_index} #{name}"
  end
end

# controll loop which selects from sqlite shows / seasons / episodes
def episodes_sql_get_all

  puts_debug "episodes_sql_get"
  db = db_setup
  
  # shows
  
  # build syntax if we looking for a specific show
  show_wanted = ''
  if $opts['show']
    show_wanted = "and title = '#{$opts['show']}'"
  end
  
  show_sql = "select id,title from metadata_items where metadata_type=2 and library_section_id in (select id from library_sections where section_type = 2) #{show_wanted} order by title"  
  db.execute( show_sql ) do |row_shows|

    # seasons
    db.execute( "select id,\"index\" from metadata_items where metadata_type=3 and parent_id=#{row_shows[0]} order by \"index\"") do |row_seasons|
      show    = row_shows[1]
      season  = row_seasons[1]
      episode = 0

      #episodes
      db.execute(  "select \"index\",title from metadata_items where metadata_type=4 and parent_id=#{row_seasons[0]} order by \"index\"" ) do |row_episodes|
        episode = row_episodes[0]
        name    = row_episodes[1]

        episodes_track show, season, episode, name
        show_print_debug show, season, episode, name 

      end
    end
  end
end

def look_for_missing
  @eps.keys.each do |show|
    @eps[show].keys.each do |season|
      @eps[show][season].keys.each do |episode|
        episode_check_previous show, season, episode
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
    @eps[show].keys.each do |season|
      @eps[show][season].keys.each do |episode|
        episodes_last[show] = show_index(season, episode)
      end
    end
  end
  debug episodes_last
end

#
# Start
#

episodes_sql_get_all
look_for_missing
#look_for_last

