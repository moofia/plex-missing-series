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

$LOAD_PATH << File.dirname(__FILE__) + '/../lib'
require "common"
require "PlexDb"
require "missing"
require "TheTvDb/TheTvDb"
require "html"

# exit on ctrl-c
trap("INT") do
  puts
  exit 2
end 

get_opts
parse_config

$plex = PlexDb.new
$plex.show = $opts['show']
$plex.episodes_get_all

if $opts['thetvdb']
  $thetvdb = TheTvDb.new
  $thetvdb.missing.process
  
  if $opts['html']
    html_create
  end
  
else 
  missing
end

