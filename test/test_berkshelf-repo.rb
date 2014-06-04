require 'json'
require 'test/unit'
require 'berkshelf-repo'

class BerkshelfRepoTest < Test::Unit::TestCase

  def setup
    @test_dir = File.dirname(__FILE__)
    @tmp="#{@test_dir}/tmp"
    @path="#{@test_dir}/path"
    @example = Hash.new
    @example[:name] = 'couchbase'
    @example[:vesion] = '1.2.0'
    @example[:content] = File.read("#{@test_dir}/data/couchbase-v1.2.0.tar.gz")
  end

  def clean
    FileUtils.rm_rf(@tmp)
    FileUtils.mkdir_p(@tmp)
    FileUtils.rm_rf(@path)
    FileUtils.mkdir_p(@path)
  end

  def test_store
    clean()
    repo=BerkshelfRepo.new(@path,@tmp)
    assert( repo.store(@example[:content], @example[:name], @example[:vesion]) )
    cbdir = "#{@path}/#{@example[:name]}/#{@example[:vesion]}"
    json_name = "#{cbdir}/data.json"

    data = JSON.parse(File.read("#{json_name}"))
    assert_equal(data,{"name" => "couchbase",
                       "version" => "1.2.0",
		       "data" => {
		         "endpoint_priority" => 0,
			 "platforms" => {
			   "amazon" => ">= 0.0.0",
   			   "centos" => ">= 0.0.0",
      			   "debian" => ">= 0.0.0",
   			   "oracle" => ">= 0.0.0",
   			   "redhat" => ">= 0.0.0",
   			   "scientific" => ">= 0.0.0",
   			   "ubuntu" => ">= 0.0.0",
   			   "windows" => ">= 0.0.0"
                        },
            "dependencies" => {
                "apt" => ">= 0.0.0",
                "openssl" => ">= 0.0.0",
                "windows" => ">= 0.0.0",
                "yum" => ">= 0.0.0"
            },"location_type" => "file_store","location_path" => "/couchbase/1.2.0/couchbase-1.2.0.tgz"}})
  end
end
