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

$script_dir = File.expand_path($0).gsub(/\/bin\/.*/,'')

# main include file for the script
require "#{$script_dir}/lib/common"
require "#{$script_dir}/lib/PlexDb"
require "#{$script_dir}/lib/missing"
require "#{$script_dir}/lib/TheTvDb/TheTvDb"
require "#{$script_dir}/lib/html"

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

