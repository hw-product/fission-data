require 'fission-data'

# Establish connection to riak
Fission::Data::ModelBase.connect!

require 'fission-data/all'
