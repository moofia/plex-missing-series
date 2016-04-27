# All Plex related things go here

# print the shows that are found only in debug mode
def plex_show_print_debug ( show, season, episode, name)
  if $opts["debug"]
    show_index = show_index season, episode
    puts "show --> #{show} #{show_index} #{name}"
  end
end

# very basic db setup
# should test / rescue sqlite3
def plex_db_setup
  
  db_file = plex_find_db
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

def plex_find_db
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
  
  puts_debug "plex_find_db using \"#{db}\""
  return db
end

# keeps track of what episodes we have
def plex_episodes_track ( episodes, show, season, episode, name)
  episodes[show]                 = {} if episodes[show].class.to_s != 'Hash'
  episodes[show][season]         = {} if episodes[show][season].class.to_s != 'Hash'
  episodes[show][season][episode] = name
end

# controll loop which selects from sqlite shows / seasons / episodes
def plex_episodes_sql_get_all

  episodes = {}
  puts_debug "episodes_sql_get"
  db = plex_db_setup
  
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

      #episodes
      db.execute(  "select \"index\",title from metadata_items where metadata_type=4 and parent_id=#{row_seasons[0]} order by \"index\"" ) do |row_episodes|
        episode = row_episodes[0]
        name    = row_episodes[1]

        plex_episodes_track episodes, show, season, episode, name
        plex_show_print_debug show, season, episode, name 

      end
    end
  end
  return episodes
end