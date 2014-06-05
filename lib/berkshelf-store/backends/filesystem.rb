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
  
    def store(content, name, version)
      digest = Digest::SHA256.hexdigest(content)
      tmp_dir = "#{@tmp}/#{digest}"
      
      FileUtils.mkdir_p "#{tmp_dir}/cookbook"
  
      return false unless write_tmp_file("#{tmp_dir}/cookbook.tgz", content)
  
      cmd = "tar --gzip --extract --file=\"#{tmp_dir}/cookbook.tgz\" -C \"#{tmp_dir}/cookbook\""
      %x{#{cmd}}
  
      if $?.exitstatus != 0
        @error="Failed to extract metadata.rb from tarball"
        return false
      end
  
      search_root = Dir["#{tmp_dir}/cookbook/*/metadata.rb"]
      if search_root.size != 1
        @error="tgz don't contains one and only on */metadata.rb"
        return false
      end
  
      File.rename(File.dirname(search_root[0]),"#{tmp_dir}/cookbook/#{name}")
  
      cookbook = Ridley::Chef::Cookbook.from_path("#{tmp_dir}/cookbook/#{name}")
      
      json_data = cookbook_data(cookbook).to_json
  
      data_dir = "#{@path}/#{name}/#{version}"
      FileUtils.mkdir_p "#{data_dir}" 
      
      json_file = File.open("#{data_dir}/data.json", "w")
      json_file.write(json_data)
      json_file.close
  
      File.rename("#{tmp_dir}/cookbook.tgz", "#{data_dir}/#{name}-#{version}.tgz")
  
      return json_data
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
          "location_type" => 'file_store',
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

    def get_catalog
      {fake:""}
    end
  end
end
