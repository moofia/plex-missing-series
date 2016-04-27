#! /usr/bin/env ruby


require 'sqlite3'
require 'getopt/long'
require 'awesome_print'
require 'yaml'

$script_dir = File.expand_path($0).gsub(/\/bin\/.*/,'')

# main include file for the script
require "#{$script_dir}/lib/common"
require "#{$script_dir}/lib/plex"
require "#{$script_dir}/lib/missing"

# exit on ctrl-c
trap("INT") do
  puts
  exit 2
end 

@script = File.basename $0 

@eps                     = {} # shit name must change
$opts                    = {}
$opts["debug"]           = 0
$opts["season_complete"] = 0  # not used yet

get_opts

help if $opts["help"]


read_config

plex_episodes_sql_get_all
look_for_missing
#look_for_last

