# anything related to directly connecting to thetvdb

# http://www.thetvdb.com/
# http://www.thetvdb.com/wiki/index.php/Programmers_API

# TODO: needs massive refactoring!

# query thetvdb.com to get the show id.
def thetvdb_get_show_id(show)
  local_file = show.gsub(/\*/,'_') # seems really spaz, should encode the file to disk
  
  show_id = ""
  cache_dir = $script_dir + "/var/thetvdb/" + local_file
  cache_dir = $config["thetvdb"]["cache_directory"] + "/" + local_file if $config["thetvdb"].has_key? "cache_directory"

  
  FileUtils.mkdir_p(cache_dir) if not File.directory? cache_dir
  cache = cache_dir + "/" + show + ".xml"
  if File.exists? cache and not $opts["tvdb-refresh"]
    parser = XML::Parser.file cache
    begin
      doc = parser.parse
    rescue => err
      log("thetvdb error: #{err} when retrieving \'#{show}\'")
      return 
    end
  else
    log_debug("thetvdb retrieving show id via www: #{show}")
    show_escaped = CGI.escape(show)
    url = $config["thetvdb"]["mirror"] + '/api/GetSeries.php?&language=en&seriesname=' + show_escaped
    xml_data =  http_get(url)
    parser = XML::Parser.string xml_data
    begin
      doc = parser.parse
    rescue => err
      log("thetvdb error: #{err} when retrieving \'#{show}\'")
      return 
    end
    File.open(cache, 'w') do |file| 
      file.puts xml_data
    end
  end
  
  doc.find('//Data/Series').each do |item|
    find = show
    find = Regexp.escape(show) if show =~ /\'|\(|\&|\*|\?/
    
    series_name = item.find('SeriesName')[0].child.to_s
    series_name = CGI.unescapeHTML(series_name)
    pre_regex = '^'

    log_debug "thetvdb looking at show of #{series_name}" if 

    if series_name  =~ /#{pre_regex}#{find}$/i     
       show_id = item.find('id')[0].child.to_s
    end

  end
  if show_id == ""
   log("thetvdb error: can not find id for show \'#{show}\'")
   show_id = false
  end
  show_id
end

# alot of the data can be cached for increased speed. 
def get_doc(show_id,show)
  local_file = show.gsub(/\*/,'_')
  cache_dir = $script_dir + "/var/thetvdb/" + local_file
  cache_dir = $config["thetvdb"]["cache_directory"] + "/" + local_file if $config["thetvdb"].has_key? "cache_directory"
  cache = cache_dir + "/" + show_id + ".xml"
  
  if File.exists? cache and not $opts["thetvdb-refresh"]
    log_debug("thetvdb retrieving episodes via cache: #{show} (#{show_id})")
    parser = XML::Parser.file cache
    doc = parser.parse
  else
    log_debug("thetvdb retrieving episodes via www: #{show} (#{show_id})")
    url = $config["thetvdb"]["mirror"] + '/api/' + $config["thetvdb"]["api_key"] + '/series/' + show_id + '/all/en.xml'
    xml_data =  http_get(url)
  
    parser = XML::Parser.string xml_data
    doc = parser.parse
    
    File.open(cache, 'w') do |file|
      file.puts xml_data
    end
  end
end

# not really sure yet on when we will force this
def force_refresh(doc)
  refresh = false
  doc.find('//Data/Series').each do |item| 
   status  = item.find('Status')[0].child.to_s
   debug status
  end
  refresh
end

# query thetvdb.com to get the episodes of the show, right now this is cached but one will have to look
# the time stamps to know when to fetch new data.
def thetvdb_get_show_episodes(show_id,show)
  episodes = {}

  doc = get_doc(show_id,show);
  #force_refresh(doc)
  
  doc.find('//Data/Episode').each do |item| 
   season       = item.find('SeasonNumber')[0].child.to_s
   episode      = item.find('EpisodeNumber')[0].child.to_s
   name         = item.find('EpisodeName')[0].child.to_s
   first_aired  = item.find('FirstAired')[0].child.to_s
   episodes[show] = Hash.new unless episodes[show].class == Hash
   episodes[show][season] = Hash.new unless episodes[show][season].class == Hash
   episodes[show][season][episode] = Hash.new unless episodes[show][season][episode].class == Hash
   episodes[show][season][episode]['name'] = name
   episodes[show][season][episode]['first_aired'] = first_aired
  end
  episodes
end

# returns a hash of episodes
def thetvdb_lookup(show)
  episodes = {}
  show_id = thetvdb_get_show_id(show)
  log_debug "thetvdb show : #{show} : show_id : #{show_id}"
  episodes = thetvdb_get_show_episodes(show_id,show) if show_id     
  return episodes
end

