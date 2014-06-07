require 'sinatra/base'
require 'sinatra/json'
#require 'berkshelf-store'

module BerkshelfStore
  class Webservice < Sinatra::Base
    helpers Sinatra::JSON

    set :prefix, "/"

    get "/ping" do
      "It's alive!!"
    end

    get "/v1/universe" do
      cookbooks_url_prefix = "#{request.base_url}/v1/cookbooks"
      storage = BerkshelfStore::Backends::Filesystem.new(settings.datadir, settings.tmpdir)
      json storage.get_catalog(cookbooks_url_prefix)
    end

    get "/v1/cookbooks/:name/:version/:filename" do
      if params[:filename] == "#{params[:name]}-#{params[:version]}.tgz"
        storage = BerkshelfStore::Backends::Filesystem.new(settings.datadir, settings.tmpdir)
        storage.get_tarball(params[:name],params[:version])
      else
        halt 400, "cookbook name should be name-version.tgz"
      end
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
