module BerkshelfStore
  ROOT = File.expand_path("../..", __FILE__)
  autoload :Backends, 'berkshelf-store/backends'
  autoload :Webservice, 'berkshelf-store/webservice'
end
