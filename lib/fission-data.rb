require 'fission-data/version'

module Fission
  module Data

    autoload :Account, 'fission-data/account'
    autoload :Identity, 'fission-data/identity'
    autoload :Job, 'fission-data/job'
    autoload :Product, 'fission-data/product'
    autoload :Repository, 'fission-data/repository'
    autoload :User, 'fission-data/user'

    autoload :ModelBase, 'fission-data/model_base'

    module Utils

      autoload :ValidationCompat, 'fission-data/utils/validation_compat'
      autoload :NamingCompat, 'fission-data/utils/naming_compat'

    end
  end
end
