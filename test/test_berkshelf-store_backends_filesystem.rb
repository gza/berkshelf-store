require 'json'
require 'test/unit'
require 'berkshelf-store'

class BerkshelfRepoBackendsFilesystemTest < Test::Unit::TestCase

  def setup
    @test_dir = File.dirname(__FILE__)
    @tarballs = "#{@test_dir}/data/tarballs"
    @dataarbo = "#{@test_dir}/data/arbo"
    @tmp="#{@test_dir}/tmp/tmp"
    @path="#{@test_dir}/tmp/path"

    #test_cases
    @test_case = Hash.new
    @test_case[:couchbase_1_2_0] = Hash.new
    @test_case[:couchbase_1_2_0][:name] = 'couchbase'
    @test_case[:couchbase_1_2_0][:version] = '1.2.0'
    @test_case[:couchbase_1_2_0][:content] = File.read("#{@tarballs}/couchbase-v1.2.0.tar.gz")
    @test_case[:couchbase_1_2_0][:json] = File.read("#{@dataarbo}/cookbooks/couchbase/1.2.0/data.json")
    @test_case[:apache2_1_10_4] = Hash.new
    @test_case[:apache2_1_10_4][:name] = 'apache2'
    @test_case[:apache2_1_10_4][:version] = '1.10.4'
    @test_case[:apache2_1_10_4][:content] = File.read("#{@tarballs}/apache2-v1.10.4-nosubdir.tar.gz")
    @test_case[:apache2_1_10_4][:json] = File.read("#{@dataarbo}/cookbooks/apache2/1.10.4/data.json")
  end

  def clean
    FileUtils.rm_rf(@tmp)
    FileUtils.mkdir_p(@tmp)
    FileUtils.rm_rf(@path)
    FileUtils.mkdir_p(@path)
  end

  def test_store
    clean()
    
    @test_case.values.each do |cookbook|
      repo=BerkshelfStore::Backends::Filesystem.new(@path,@tmp)

      cbdir = "#{@path}/#{cookbook[:name]}/#{cookbook[:version]}"
      #Must not exists before
      assert(! File.exists?(cbdir))

      result_store = repo.store(cookbook[:content])

      assert(File.exists?(cbdir))
      assert(File.exists?("#{cbdir}/#{cookbook[:name]}-#{cookbook[:version]}.tgz"))
      assert(File.exists?("#{cbdir}/data.json"))
      
      assert( result_store )

      generated_data = JSON.parse(File.read("#{cbdir}/data.json"))
      control_data = JSON.parse(cookbook[:json])
      assert_equal(control_data, generated_data)

      #Ensure cleaning is done
      assert(Dir["#{@tmp}/*"].size == 0)
    end 
  end

  def test_store_bad_tgz
    clean()
    repo=BerkshelfStore::Backends::Filesystem.new(@path,@tmp)
    result_store = repo.store("this is not tgz data, hi hi")
    assert( result_store.key?('fail') )
  end

  def test_store_not_cookbook_tgz
    clean()
    repo=BerkshelfStore::Backends::Filesystem.new(@path,@tmp)
    result_store = repo.store(File.read("#{@tarballs}/not_a_cookbook.tgz"))
    assert( result_store.key?('fail') )
  end

  def test_get_catalog
    clean()

    repo=BerkshelfStore::Backends::Filesystem.new("#{@dataarbo}/cookbooks", @tmp)
    generated_data = repo.get_catalog("http://localhost")
    control_data = JSON.parse(File.read("#{@test_dir}/data/catalog.json"))
    assert_equal(control_data, generated_data)
  end
end
