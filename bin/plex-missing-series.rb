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
require "#{$script_dir}/lib/plex"
require "#{$script_dir}/lib/missing"
require "#{$script_dir}/lib/http"
require "#{$script_dir}/lib/thetvdb"
require "#{$script_dir}/lib/thetvdb_last"

# exit on ctrl-c
trap("INT") do
  puts
  exit 2
end 

@script = File.basename $0 

get_opts
parse_config

episodes = plex_episodes_sql_get_all

if $opts['thetvdb']
  thetvdb_last episodes
else 
  look_for_missing episodes
end

