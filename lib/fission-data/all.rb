require 'fission-data'

# Force load constants (generally used for rails)
%w(Account Identity Job Product Repository User).each do |klass|
  Fission::Data.const_get(klass)
end

# Inject into top level namespace
if(defined?(Rails))
  Object.send(:include, Fission::Data)
end
