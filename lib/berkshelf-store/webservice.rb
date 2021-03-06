require 'sinatra/base'
require 'sinatra/json'
require 'syslog-logger'
require 'logger'

#require 'berkshelf-store'
::Logger.class_eval { alias :write :'<<' }
::Logger::Syslog.class_eval { alias :write :'<<' }

module BerkshelfStore
  class Webservice < Sinatra::Base
    helpers Sinatra::JSON

    helpers do
      def logger
        settings.logger
      end
    end

    configure do
      logger_type = ENV['LOGGER_TYPE'].to_s
      logger_conf = ENV['LOGGER_CONF'].to_s
      if logger_type == "file"
        logger = Logger.new(File.open("#{logger_conf}", 'a'))
      elsif logger_type == "stderr"
        logger = Logger.new(STDERR)
      elsif logger_type == "syslog"
        programname = logger_conf.split(".")[0]
        facility = eval("Syslog::LOG_#{logger_conf.to_s.split(".")[1].upcase}")
        logger = Logger::Syslog.new(programname, facility)
      end
      use ::Rack::CommonLogger, logger
      set :logger, logger

      #static files (UI) stuff
      #et :public_folder, BerkshelfStore::ROOT + '/www/static'

    end
    set :prefix, "/"
    set :public_folder, BerkshelfStore::ROOT + '/ui/static'
    set :views, BerkshelfStore::ROOT + '/ui/views'


    get "/ping" do
      logger.info 'ping'
      json({'info'    => 'berkshelf-store',
            'version' => 'it would be nice to show it :)',
            'status'  => 'seems to work :)'})
    end

    get "/v1/universe" do
      cookbooks_url_prefix = "#{request.base_url}/v1/cookbooks"
      storage = BerkshelfStore::Backends::Filesystem.new(settings.datadir, settings.tmpdir)
      json(storage.get_catalog(cookbooks_url_prefix))
    end

    get "/v1/cookbooks/:name/:version/:filename" do
      if params[:filename] == "#{params[:name]}-#{params[:version]}.tgz"
        storage = BerkshelfStore::Backends::Filesystem.new(settings.datadir, settings.tmpdir)
        storage.get_tarball(params[:name],params[:version])
      else
        halt 400, json({'fail' => 'cookbook name should be name-version.tgz'})
      end
    end

    post "/v1/cookbooks" do
      if params.key?("cookbook")
        storage = BerkshelfStore::Backends::Filesystem.new(settings.datadir, settings.tmpdir)
        cookbook_data = storage.store(params["cookbook"][:tempfile].read)
        if cookbook_data.key?('name')
          json cookbook_data
        else
          halt 500, json(cookbook_data)
        end
      else
        halt 400, json({'fail' => 'Wrong parameters'})
      end
    end

    get "/" do
      redirect "/index.html"
    end

    get "/:name.html" do
      @site_prefix="#{request.base_url}"
      @ws_prefix="/v1"
      @active="#{params[:name]}" 
      if params[:name] == 'index'
        erb :catalog
      elsif params[:name] == 'upload'
        erb :upload
      elsif params[:name] == 'doc'
        erb :doc
      else
        halt 404, "<h1>page #{params[:name]}.html not found</h1>"
      end
    end

  end
end
