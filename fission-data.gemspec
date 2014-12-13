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
  s.add_dependency 'hashie'
  s.add_dependency 'sequel'
  s.add_dependency 'pg'
  s.files = Dir['{lib}/**/**/*'] + %w(fission-data.gemspec README.md CHANGELOG.md)
end
