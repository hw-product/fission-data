require 'fission-data'

# Establish database connection
Fission::Data.connect!

Thread.exclusive{ Fission::Data::Models.constants.each{|k| Fission::Data::Models.const_get(k)} }

if(defined?(Rails))
  require 'fission-data/rails-init'
end
