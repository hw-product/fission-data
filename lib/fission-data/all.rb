require 'fission-data'

# Force load constants (generally used for rails)
Dir.glob(File.join(File.dirname(__FILE__), defined?(Fission::Data::Sql) ? 'sql' : 'riak', '*.*')).each do |path|
  klass = File.basename(path).sub(File.extname(path), '').split('_').map(&:capitalize).join.to_sym
  Fission::Data.const_get(klass)
end

# Inject into top level namespace
if(defined?(Rails))
  Object.send(:include, Fission::Data)
end
