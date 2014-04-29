require 'fission-data'

# Inject into top level namespace
if(defined?(Rails))
  Object.send(:include, Fission::Data)
end
