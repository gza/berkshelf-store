require 'sinatra/base'
#require 'berkshelf-store'

module BerkshelfStore
  class Webservice < Sinatra::Base

    get "/ping" do
      "It's alive!!"
    end

    get "/v1" do
      storage = BerkshelfStore::Backends::Filesystem.new(settings.datadir, settings.tmpdir)
      storage.get_catalog()
    end

    post "/v1/cookbooks/:name/:version" do
      if params.key?("cookbook") && params.key?("name") && params.key?("version")
        storage = BerkshelfStore::Backends::Filesystem.new(settings.datadir, settings.tmpdir)
	jsondata = storage.store(params["cookbook"][:tempfile].read, params[:name], params[:version])
	if jsondata.size > 10
          jsondata
	else
          halt 500, storage.last_error
	end
      else
        halt 500, 'Wrong parameters'
      end
    end

  end
end
