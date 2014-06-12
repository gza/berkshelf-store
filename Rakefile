require 'rake/testtask'
require 'net/http'

STATICDIR='ui/static'

desc "Run tests"
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

task :default => :build

task :build => [ :test, :vendor ] do
  system "gem build berkshelf-store.gemspec"
end

directory "#{STATICDIR}"
task :vendor => [ "#{STATICDIR}/bootstrap", "#{STATICDIR}/jquery/jquery.min.js", "#{STATICDIR}/jquery_file_upload" ] do
  puts "Vendored"
end

desc "Get bootstrap"
directory "#{STATICDIR}/bootstrap" do
  version = "3.1.1"
  system "wget https://github.com/twbs/bootstrap/releases/download/v#{version}/bootstrap-#{version}-dist.zip -O #{STATICDIR}/bootstrap.zip"
  system "cd #{STATICDIR}; unzip bootstrap.zip; mv bootstrap-#{version}-dist bootstrap; rm bootstrap.zip"
end

desc "Get jquery"
file "#{STATICDIR}/jquery/jquery.min.js" do
  version = "1.11.1"
  system "mkdir #{STATICDIR}/jquery"
  system "wget http://code.jquery.com/jquery-#{version}.min.js -O #{STATICDIR}/jquery/jquery.min.js"
end

desc "Get jquery file upload"
directory "#{STATICDIR}/jquery_file_upload" do
  version = "9.5.7"
  system "wget https://github.com/blueimp/jQuery-File-Upload/archive/#{version}.tar.gz -O #{STATICDIR}/jquery_file_upload.tgz"
  system "cd #{STATICDIR}; tar xvzf jquery_file_upload.tgz; mv jQuery-File-Upload-#{version} jquery_file_upload; rm jquery_file_upload.tgz"
end

