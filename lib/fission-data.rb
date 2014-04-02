require 'fission-data/version'

if(ENV['FISSION_DATA_TYPE'])
  require "fission/#{ENV['FISSION_DATA_TYPE']}"
else
  require 'fission-data/riak'
end

module Fission
  module Data

    autoload :Error, 'fission-data/errors'
    autoload :ModelInterface, 'fission-data/model_interface'
    autoload :Hash, 'fission-data/utils/hash'

    module Utils

      autoload :ValidationCompat, 'fission-data/utils/validation_compat'
      autoload :NamingCompat, 'fission-data/utils/naming_compat'

    end
  end
end
