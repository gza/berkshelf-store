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
    end
    set :prefix, "/"

    get "/ping" do
      logger.info 'ping'
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
