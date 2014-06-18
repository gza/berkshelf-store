require 'digest'
require 'json'
require 'fileutils'
require 'ridley'

module BerkshelfStore::Backends
  class Filesystem

    @error = ''
  
    def initialize(path, tmp)
      @path = path
      @tmp = tmp
    end
  
    def check_filename(filename)
      #do minimal checks
      true
    end
  
    def store(content)
      data = {}

      digest = Digest::SHA256.hexdigest(content)
      tmp_dir = "#{@tmp}/#{digest}"
      
      FileUtils.mkdir_p "#{tmp_dir}/cookbook"

      #extract cookbook
      if write_tmp_file("#{tmp_dir}/cookbook.tgz", content)
        cmd = "tar --gzip --extract --file=\"#{tmp_dir}/cookbook.tgz\" -C \"#{tmp_dir}/cookbook\""
        %x{#{cmd}}
  
        if $?.exitstatus != 0
          return {"fail" => "Failed to extract metadata.rb from tarball"}
        end
      else
        return {"fail" => "Unable to write cookbook #{tmp_dir}/cookbook.tgz"}
      end
  
      #locate check cookbook
      search_root = Dir["#{tmp_dir}/cookbook/*/metadata.rb", "#{tmp_dir}/cookbook/metadata.rb"]
      if search_root.size != 1
        return {"fail" => "tgz don't contains one and only on */metadata.rb"}
      end
      cookbook_dir = File.dirname(search_root[0])
        
      #Extract information
      begin
        cookbook = Ridley::Chef::Cookbook.from_path(cookbook_dir)
        data = cookbook_data(cookbook)
        name = data['name']
        version = data['version']
      rescue Exception => e
        return {"fail" => "Information extraction failed #{e}"}
      end

      begin
        data_dir = "#{@path}/#{name}/#{version}"
        FileUtils.mkdir_p "#{data_dir}" 
      rescue SystemCallError => e
        return {"fail" => "#{data_dir} creation failed #{e}"}
      end

      begin
        json_file = File.open("#{data_dir}/data.json", "w")
        json_file.write(data.to_json)
        json_file.close
      rescue Exception => e
        return {"fail" => "#{data_dir}/data.json creation failed #{e}"}
      end
  
      begin
        File.rename("#{tmp_dir}/cookbook.tgz", "#{data_dir}/#{name}-#{version}.tgz")
      rescue Exception => e
        return {"fail" => "tarball store failed #{e}"}
      end

      FileUtils.rm_rf("#{tmp_dir}")
      return data
    end
  
    def cookbook_data(cookbook)
      platforms = cookbook.metadata.platforms || Hash.new
      dependencies = cookbook.metadata.dependencies || Hash.new
  
      name = cookbook.cookbook_name.to_s
      version = cookbook.version.to_s
  
      path = "/#{name}/#{version}/#{name}-#{version}.tgz"
  
      retval = {
        "name" => name,
        "version" => version,
        "data" => {
          "endpoint_priority" => 0,
          "platforms" => platforms,
          "dependencies" => dependencies,
          "location_type" => 'uri',
          "location_path" => path
        }
      }
      return retval
    end
  
    def write_tmp_file(name, content)
      begin
        tarfile = File.open("#{name}", "w")
        tarfile.write(content)
      rescue IOError => e
        @error="Failed to write temp file #{name}"
        return false
      ensure
        tarfile.close unless tarfile == nil
      end
    end

    def last_error
      @error
    end

    def get_json(name, version)
      File.open("#{@path}/#{name}/#{version}/data.json", "r").read
    end

    def get_tarball(name, version)
      File.open("#{@path}/#{name}/#{version}/#{name}-#{version}.tgz").read
    end

    def get_catalog(prefix)
      retval = {}
      Dir["#{@path}/*/*/data.json"].each do |json_file|
         data = JSON.parse(File.read("#{json_file}"))
	 data['data']['location_path'] = "#{prefix}#{data['data']['location_path']}"
	 retval[data['name']] ||= Hash.new
	 retval[data['name']][data['version']] = data['data']
      end
      retval
    end
  end
end
