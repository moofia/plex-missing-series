# All Plex related things go here

class PlexDb
  attr_reader :episodes
  attr_accessor :show, :episodes_missing
  
  def initialize
    @episodes         = {}
    @episodes_missing = {}
    db_setup
  end
  
  # print the shows that are found only in debug mode
  def found_debug ( show, season, episode, name)
    show_index = show_index season, episode
    #log_debug "found --> #{show} #{show_index} #{name}"
  end
  
  # very basic db setup
  # should test / rescue sqlite3
  def db_setup
    log_debug
    db_file = find_db
    db_tmp  = '/tmp/plex_missing_tmp.db'
    @db     = ''
    
    # cp to tmp as the db is locked if being used
    `cp "#{db_file}" #{db_tmp}`
  
    # not too sure why but i was having a problem where a 0 byte file was cp'd
    # def a local issue i assume but the check was needed
    if test ?s, db_tmp
      @db = SQLite3::Database.new db_tmp
    else 
      puts "error-> can not open #{db_tmp} for reasing"
      exit 2
    end
  end
  
  def find_db
    log_debug
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
    
    log_debug "find_db using \"#{db}\""
    return db
  end
  
  # keeps track of what episodes we have
  def episodes_track ( episodes, show, season, episode, name)
    episodes[show]                 = {} if episodes[show].class.to_s != 'Hash'
    episodes[show][season]         = {} if episodes[show][season].class.to_s != 'Hash'
    episodes[show][season][episode] = name
  end
  
  def sql_select(sql)
    rows = []
    begin
      rows = @db.execute( sql )
    rescue => err
      log("sqlite error: #{err}")
      exit 2
    end
    
    rows
  end
  
  # get all the episodes
  def episodes_get_all
  log_debug

  # build syntax if we looking for a specific show
  show_wanted = ''
    
  if self.show
    show_wanted = "and title = '#{self.show}'"
  end
  
  sql_shows   = "select id,title from metadata_items where metadata_type=2 and library_section_id in (select id from library_sections where section_type = 2) #{show_wanted} order by title"  
  
  sql_select(sql_shows).each do |row_shows|

    sql_seasons = "select id,\"index\" from metadata_items where metadata_type=3 and parent_id=#{row_shows[0]} order by \"index\""
    sql_select(sql_seasons).each do  |row_seasons|
      show    = row_shows[1]
      season  = row_seasons[1]
      
      sql_episodes = "select \"index\",title from metadata_items where metadata_type=4 and parent_id=#{row_seasons[0]} order by \"index\""
      sql_select(sql_episodes).each do |row_episodes|
        episode = row_episodes[0]
        name    = row_episodes[1]
      
        episodes_track @episodes, show, season, episode, name
        found_debug show, season, episode, name 
      
        end
      end
    end

  end

end