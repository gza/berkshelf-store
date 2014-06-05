#!/usr/bin/env ruby
$:.push File.expand_path("../../lib", __FILE__)

require 'berkshelf-store'

BerkshelfStore::Webservice.run!({datadir:'/var/lib/berkshelf-store/cookbooks', tmpdir:'/var/tmp/berkshelf-store'})
