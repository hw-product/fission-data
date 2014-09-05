require 'fission-data'

# Establish database connection
Fission::Data.connect!

if(defined?(Rails))
  require 'fission-data/rails-init'
end
