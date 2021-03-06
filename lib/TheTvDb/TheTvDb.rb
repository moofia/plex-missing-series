# anything related to directly connecting to thetvdb

# http://www.thetvdb.com/
# http://www.thetvdb.com/wiki/index.php/Programmers_API

# TODO: needs massive refactoring!

# moo = MoofiaTheTvDb.new
# moo.thetvdb_get("Bones")
# moo.thetvdb_get("Awkward.")
# puts moo.episodes.class

$LOAD_PATH << File.join(File.dirname(__FILE__))
require 'http'
require "TheTvDbMissing"

class TheTvDb
  attr_accessor :episodes, :missing
  
  def initialize
    @episodes = {}
    self.missing = TheTvDbMissing.new
  end
  
  # handles retrieval of xml
  def get_xml(show, url, filename)
    log_debug
    
    local_file = show.gsub(/\*/,'_') # seems really spaz, should encode the file to disk
    
    cache_dir = $config['script_dir'] + '/var/thetvdb/' + local_file
    cache_dir = $config["thetvdb"]["cache_directory"] + "/" + local_file if $config["thetvdb"].has_key? "cache_directory"
  
    FileUtils.mkdir_p(cache_dir) if not File.directory? cache_dir
    cache = cache_dir + "/" + filename + ".xml"
      
    if File.exists? cache and not $config["tvdb-refresh"]
      
      log_debug("thetvdb cache: #{cache}")
      parser = XML::Parser.file cache
      begin
        doc = parser.parse
      rescue => err
        log("thetvdb error: #{err} when retrieving \'#{show}\'")
        return 
      end
    else
      log_debug("thetvdb direct: #{url}")
      
      xml_data =  http_get(url)
      parser   = XML::Parser.string xml_data
      
      begin
        doc = parser.parse
      rescue => err
        log("thetvdb error: #{err} when retrieving \'#{show}\'")
        return 
      end
      log_debug("saving cache \"#{cache}\"")
      File.open(cache, 'w') do |file| 
        file.puts xml_data
      end
    end
    return doc
  end
  
  # query thetvdb.com to get the show id.
  def api_show_id(show)
    log_debug
    show_escaped = CGI.escape(show)
    url = $config["thetvdb"]["mirror"] + '/api/GetSeries.php?&language=en&seriesname=' + show_escaped
    $config["tvdb-refresh"] = false;
    doc     = get_xml(show, url, show)
    show_id = ""
    
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
  
  # query thetvdb.com to get the episodes of the show, right now this is cached but one will have to look
  # the time stamps to know when to fetch new data.
  def api_series(show_id,show)
    log_debug
    $config["tvdb-refresh"] = true;
    
    check_cache  
  
    url = $config["thetvdb"]["mirror"] + '/api/' + $config["thetvdb"]["api_key"] + '/series/' + show_id + '/all/en.xml'  
    doc = get_xml(show, url, show_id)
  
    @episodes[show] = Hash.new unless @episodes[show].class == Hash
  
    show_info(doc, show)
    episode_info(doc, show)
    
  end
  
  # not really sure yet on when we will force this
  # XXX: not used
  def force_refresh(doc)
    log_debug
    refresh = false
    doc.find('//Data/Series').each do |item| 
     status  = item.find('Status')[0].child.to_s
     debug status
    end
    refresh
  end
  
  # starts by looking at the cli argument
  # at a later stage can be more logical about when one should fetch live vs cache
  def check_cache
    log_debug
    
    if $opts['cache']
      $config["tvdb-refresh"] = false;
    end
    
  end
  
  # extracts info about the show from XML using the
  # episodes XML
  def show_info(doc, show)
    doc.find('//Data/Series').each do |item| 
      @episodes[show]['genre']    = item.find('Genre')[0].child.to_s
      @episodes[show]['imdb_id']  = item.find('IMDB_ID')[0].child.to_s
      @episodes[show]['overview'] = item.find('Overview')[0].child.to_s
      @episodes[show]['status']   = item.find('Status')[0].child.to_s
      @episodes[show]['banner']   = item.find('banner')[0].child.to_s
      @episodes[show]['poster']   = item.find('poster')[0].child.to_s
      @episodes[show]['fanart']   = item.find('fanart')[0].child.to_s
      @episodes[show]['id']       = item.find('id')[0].child.to_s
   end
    
   @episodes[show]['genre'].gsub!(/^\|/,'')
   @episodes[show]['genre'].gsub!(/\|$/,'')
   @episodes[show]['genre'].gsub!(/\|/,' | ')
  end
  
  def episode_info(doc, show)
    doc.find('//Data/Episode').each do |item| 
     season       = item.find('SeasonNumber')[0].child.to_s
     episode      = item.find('EpisodeNumber')[0].child.to_s
     name         = item.find('EpisodeName')[0].child.to_s
     first_aired  = item.find('FirstAired')[0].child.to_s
     @episodes[show]['episodes'] = Hash.new unless @episodes[show]['episodes'].class == Hash
     @episodes[show]['episodes'][season] = Hash.new unless @episodes[show]['episodes'][season].class == Hash
     @episodes[show]['episodes'][season][episode] = Hash.new unless @episodes[show]['episodes'][season][episode].class == Hash
     @episodes[show]['episodes'][season][episode]['name'] = name
     @episodes[show]['episodes'][season][episode]['first_aired'] = first_aired
     @episodes[show]['episodes'][season][episode]['overview']    = item.find('Overview')[0].child.to_s
    end
  end
  
  # returns a hash of episodes
  def show(show)
    log_debug
    show_id  = api_show_id(show)

    if show_id
      log_debug "thetvdb show : #{show} : show_id : #{show_id}"
      api_series(show_id,show) 
    end
    
  end

end