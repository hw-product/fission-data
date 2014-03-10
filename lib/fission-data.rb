require 'fission-data/version'

if(ENV['FISSION_DATA_TYPE'])
  require "fission/#{ENV['FISSION_DATA_TYPE'}"
end

module Fission
  module Data

    autoload :Error, 'fission-data/errors'

    module Utils

      autoload :ValidationCompat, 'fission-data/utils/validation_compat'
      autoload :NamingCompat, 'fission-data/utils/naming_compat'

    end
  end
end
