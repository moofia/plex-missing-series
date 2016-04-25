#! /usr/bin/env ruby


require 'sqlite3'
require 'getopt/long'
require 'awesome_print'

@script = File.basename $0 

@eps             = {}
$opts            = {}
$opts["debug"]   = 0
@season_complete = 0  # not used yet

def help

  puts <<-EOF
#{@script} [OPTIONS]

  --help            help
  --debug           debugging enable
  
  
EOF
  exit
end

# options 
begin
  $opts = Getopt::Long.getopts(
    ["--debug", Getopt::BOOLEAN],
    ["--help",  Getopt::BOOLEAN],
    )
rescue Getopt::Long::Error => e
  puts "#{@script} -> error #{e.message}"  
  puts 
  help
end

help if $opts["help"]

def debug(what)
  puts "#{@script} --> debug and exit..\n"
  ap what
  exit
end

def create_number(season, episode)

  if ( episode < 10 ) 
    episode = "0#{episode}"
  end
  if ( season < 10 ) 
    season = "0#{season}"
  end

  show_index = "s#{season}e#{episode}"
  return show_index

end

def seen_episodes ( show, season, episode, name)
  @eps[show]                 = {} if @eps[show].class.to_s != 'Hash'
  @eps[show][season]         = {} if @eps[show][season].class.to_s != 'Hash'
  @eps[show][season][episode] = name
end

def find_db
  file_name = 'com.plexapp.plugins.library.db'
  paths     = [ '.',
                '/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-in Support/Databases',
                "#{ENV['HOME']}/Library/Application Support/Plex Media Server/Plug-in Support/Databases/"
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
    puts "error : could not find db file"
    exit 2
  end
  
  return db
end

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

def print_missing (show, pair)
  puts "show --> #{show} #{pair} !!MISSING!!"
end

def process_missing (show, pair)
  print_missing show, pair
end

# check if we have the previous episode
def check_previous_episode ( show, season, episode)

  missing = {}

  for i in (episode - 1).downto(1)
    if not @eps[show][season][i]
      missing_index = create_number season, i
      missing[i] = "#{show};#{missing_index}"
    else 
      break
    end
  end

  missing.keys.sort.each do |i| 
    if not missing[1]
      process_missing missing[i].split(';')[0] , missing[i].split(';')[1]
    end
  end

end

# print the shows that are found only in debug mode
def print_show ( show, season, episode, name)
  if $opts["debug"]
    show_index = create_number season, episode
    puts "show --> #{show} #{show_index} #{name}"
  end
end

def get_episodes

  db = db_setup
  # shows
  db.execute( "select id,title from metadata_items where metadata_type=2 and library_section_id in (select id from library_sections where section_type = 2) order by title" ) do |row_shows|

    # seasons
    db.execute( "select id,\"index\" from metadata_items where metadata_type=3 and parent_id=#{row_shows[0]} order by \"index\"") do |row_seasons|
      show    = row_shows[1]
      season  = row_seasons[1]
      #next if show !~ /Arrested/
      #next if season != 1
      episode = 0

      #episodes
      db.execute(  "select \"index\",title from metadata_items where metadata_type=4 and parent_id=#{row_seasons[0]} order by \"index\"" ) do |row_episodes|
        episode = row_episodes[0]
        #next if episode < 16
        name    = row_episodes[1]

        seen_episodes show, season, episode, name
        check_previous_episode show, season, episode
        print_show show, season, episode, name 

      end
    end
  end
end

#
# Start
#

get_episodes

