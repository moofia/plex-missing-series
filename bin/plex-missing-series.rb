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

# options 
begin
  $opts = Getopt::Long.getopts(
    ["--debug", Getopt::BOOLEAN],
    ["--help",  Getopt::BOOLEAN],
    ["--show",  Getopt::OPTIONAL],
    )
rescue Getopt::Long::Error => e
  puts "#{@script} -> error #{e.message}"  
  puts 
  help
end

help if $opts["help"]

begin
  $config = YAML::load(File.read("#{$script_dir}/etc/config.defaults.yaml"))
rescue => e
  puts "#{@script} -> yaml error #{e.message}"  
  exit 2
end

plex_episodes_sql_get_all
look_for_missing
#look_for_last
