#! /usr/bin/env ruby

require 'sqlite3'
require 'getopt/long'
require 'awesome_print'
require 'yaml'
require 'fileutils'
require 'net/http'
require 'xml/libxml'
require 'cgi'
require 'date'
require 'json'

$LOAD_PATH << File.dirname(__FILE__) + '/../lib'
require "common"
require "PlexDb"
require "missing"
require "TheTvDb/TheTvDb"
require "html"
require "Sonarr/Sonarr"


# exit on ctrl-c
trap("INT") do
  puts
  exit 2
end 

get_opts
parse_config

$plex = PlexDb.new
$plex.show = $opts['show']
$plex.episodes_get

# lazy ... sonarr stuff

if $opts['sonarr-sync']
  
  sonarr = Sonarr.new
  
  $plex.shows.keys.each do |show|
    if $plex.shows[show]['tvdb_id']
      sonarr.series_add show, $plex.shows[show]['tvdb_id'], $plex.shows[show]['path']
    else 
      log_error("[#{show}] tvdb id can not be null!")
      log("exiting, fix error above")
      exit
    end
  end

end





exit

if $opts['thetvdb']
  $thetvdb = TheTvDb.new
  $thetvdb.missing.get
  
  if $opts['html']
    html_create
  end
  
else 
  missing
end

