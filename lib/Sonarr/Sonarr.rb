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

class Sonarr
  #attr_accessor :episodes, :missing
  
  def initialize
   # @episodes = {}
    #self.missing = TheTvDbMissing.new
    
    if not valid_config
      log("Error: invalid Sonarr config!")
      exit 2
    end
  
  end
  
  def handle_response(show, res)
    json = JSON.parse(res.body)
    
    if json.class.to_s == 'Hash'
      if json.has_key? 'message'
        log_error "#{show} --> JSON key 'message' : #{json['message']}"
      end
      if json.has_key? 'id'
        if json['id'] > 0
          log "Sonarr: #{show} added successfully"
        end
      end
      
    elsif json.class.to_s == 'Array'
      json.each do |row|
       log_error ("#{show} #{row['propertyName']} -> #{row['errorMessage']}")
       #series_dump_show(series_get_all, show)
      end
      #log_error ("for now we exit on first error")
      #debug json
  
    else
      log_debug("dont know what to do with the returned api data")
      debug json
    end
    
    
  end
  
  def series_dump_show(json, show)
    if json.class.to_s == 'Array'
      json.each do |row|
        if row['title'] == show
          ap row
        end
      end
    end
  end
  
  # dirty example of getting all shows, might be used for a diff later
  # or to remove shows that exist in Sonarr but not in Plex
  def series_get_all
    begin
      api = "#{$config['sonarr']['api_url']}/series"

      url = URI.parse(api)

      req = Net::HTTP::Get.new(url.path)
      req.add_field('Content-Type', 'application/json')
      req.add_field('X-Api-Key',$config['sonarr']['api_key'])

      res = Net::HTTP.new(url.host, url.port).start do |http|
        http.request(req)
      end

    json = JSON.parse(res.body)
    #if json.class.to_s == 'Array'
    #  json.each do |row|
    #   log_debug ("#{row['title']}")
    #  end
    #end

    rescue => e
      log_debug "failed #{e}"
     end
     return json
  end
  
  def series_add(show, tvdb_id, path)
    begin
      api = "#{$config['sonarr']['api_url']}/series"
      log_debug(api)
      uri = URI(api)
      http = Net::HTTP.new(uri.host, uri.port)
      req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json', 'X-Api-Key'=> $config['sonarr']['api_key'])
      
      json = {}
      json['title']            = show
      json['images']           = []
      json['seasons']          = []
      json['monitored']        = 'false'
      json['seasonFolder']     = 'true'
      json['path']             = path
      json['profileId']        = 1
      json['tvdbId']           = tvdb_id
      json['titleSlug']        = show.gsub(/ /, '-')
      json['qualityProfileId'] = 1
      json['titleSlug'].downcase!
      
      #season = {}
      #season['seasonNumber'] = 7
      #season['monitored'] = 'true'
      #json['seasons'].push(season)
      #
      
      req.body = json.to_json

      res = http.request(req)
      handle_response show, res
    rescue => e
      log_error "connecting to #{api} : #{e}"
     end
  end
  
  # stupid you need to know the id and can get a show by its name
  def series_get(id)
    begin
      api = "#{$config['sonarr']['api_url']}/series/#{id}"
      log_debug(api)
      uri = URI(api)
      http = Net::HTTP.new(uri.host, uri.port)
      req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json', 'X-Api-Key'=> $config['sonarr']['api_key'])
      
      json = {}
      json['id'] = id
      
      req.body = json.to_json
      res      = http.request(req)      
      json     = JSON.parse(res.body)
      debug json
    rescue => e
      puts "failed #{e}"
     end
  end
  
  # basic check of the config
  def valid_config
    success = false
    
    if $config['sonarr']
      if $config['sonarr']['enable']
        if $config['sonarr']['api_key'] =~ /\w/ and $config['sonarr']['api_url'] =~ /\w/
          success = true
        end
        
      end
    end
    
    return success
  end
  
  
  
  

end