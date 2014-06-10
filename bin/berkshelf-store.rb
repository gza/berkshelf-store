#!/usr/bin/env ruby
$:.push File.expand_path("../../lib", __FILE__)

require 'optparse'
require 'berkshelf-store'

options = {
        datadir:"./datadir",
        tmpdir:"./tmpdir",
        bind:"127.0.0.1",
        port:"80",
        logger_type:"syslog",
        logger_conf:"berkshelf-store.daemon"
}

OptionParser.new do |opts|
  opts.banner = "Usage: berkshelf-store.rb [options]"

  opts.on("-D", "--datadir DIRECTORY", "Data directory (default: #{options[:datadir]})") do |d|
    options[:datadir] = d
  end

  opts.on("-T", "--tmpdir DIRECTORY", "Tmp directory (default: #{options[:tmpdir]})") do |t|
    options[:tmpdir] = t
  end

  opts.on("-b", "--bind IP", "bind IP (default: #{options[:bind]})") do |ip|
    options[:bind] = ip
  end

  opts.on("-p", "--port PORT", "port to listen on (default: #{options[:port]})") do |p|
    options[:port] = p
  end
 
  opts.on("-l", "--logger TYPE", "file, syslog, stderr (default: #{options[:logger_type]})") do |l|
    options[:logger_type] = l
  end
  
  opts.on("-L", "--logger-conf TYPE", "file: filename, syslog: program.facility, stderr n/a (default: #{options[:logger_conf]})") do |lc|
    options[:logger_conf] = lc
  end
end.parse!

p options

#The only way I found to pass options to configure
ENV['LOGGER_TYPE'] ||= options.delete(:logger_type)
ENV['LOGGER_CONF'] ||= options.delete(:logger_conf)

#remaining options will be available as settings
BerkshelfStore::Webservice.run!(options)
