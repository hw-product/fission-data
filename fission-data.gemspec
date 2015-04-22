$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'fission-data/version'
spec = Gem::Specification.new do |s|
  s.name = 'fission-data'
  s.version = Fission::Data::VERSION.version
  s.summary = 'Fission Data'
  s.author = 'Heavywater'
  s.email = 'fission@hw-ops.com'
  s.homepage = 'http://github.com/heavywater/fission-data'
  s.description = 'Fission Core'
  s.require_path = 'lib'
  s.add_runtime_dependency 'hashie'
  s.add_runtime_dependency 'sequel'
  s.add_runtime_dependency 'fission', '>= 0.1.5'
  if(RUBY_PLATFORM == 'java' || ENV['BUILD_JAVA'])
    s.platform = 'java'
    s.add_runtime_dependency 'jdbc-postgres'
  else
    s.add_runtime_dependency 'pg'
  end
  s.files = Dir['{lib}/**/**/*'] + %w(fission-data.gemspec README.md CHANGELOG.md)
end
