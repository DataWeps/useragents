# encoding:utf-8

# require lib dir
lib_dir    = File.expand_path('../lib', __FILE__)
config_dir = File.expand_path('../config', __FILE__)
$LOAD_PATH << lib_dir unless $LOAD_PATH.include?(lib_dir)
$LOAD_PATH << config_dir
require './lib/app'

run BrowserHeaders
