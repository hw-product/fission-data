require 'fission-data/version'

module Fission
  module Data

    autoload :Error, 'fission-data/errors'
    autoload :ModelInterface, 'fission-data/model_interface'
    autoload :Hash, 'fission-data/utils/hash'

    module Utils

      autoload :ValidationCompat, 'fission-data/utils/validation_compat'
      autoload :NamingCompat, 'fission-data/utils/naming_compat'
      autoload :Cipher, 'fission-data/utils/cipher'

    end
  end
end

if(ENV['FISSION_DATA_TYPE'])
  require "fission-data/#{ENV['FISSION_DATA_TYPE']}"
else
  require 'fission-data/riak'
end
