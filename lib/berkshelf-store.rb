module BerkshelfStore
  ROOT = File.expand_path("../..", __FILE__)
  VERSION = "0.3.0"
  autoload :Backends, 'berkshelf-store/backends'
  autoload :Webservice, 'berkshelf-store/webservice'
end
