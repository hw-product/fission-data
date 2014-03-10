require 'fission-data'

module Fission
  module Data
    module Riak
      class Product < ModelBase

        bucket :products

        value :name, :class => String
        value :status, :class => String
        value :enabled, :default => true

        links :enabled_accounts, Account, :to => :products

      end

    end
    Product = Riak::Product
  end
end
