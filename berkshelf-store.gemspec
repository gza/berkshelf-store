# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "berkshelf-store"
  s.version     = "0.1.0"
  s.authors     = ["Guillaume Zitta"]
  s.email       = ["github.guillaume@zitta.fr"]
  s.homepage    = "https://github.com/gza/berkshelf-store"
  s.summary     = "A cookbook store based on the berkshelf API"
  s.description = s.summary

  s.rubyforge_project = "berkshelf-store"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'syslog-logger'
  s.add_dependency 'ridley'
  s.add_dependency 'sinatra', '>=1.4.5'
  s.add_dependency 'sinatra-contrib', '>=1.4.2'

  s.add_development_dependency 'rake'
end
