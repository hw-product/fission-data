require 'fission-data'

module Fission
  module Data
    module Models

      # Price of an item
      class Price < Sequel::Model

        many_to_many :product_features
        many_to_many :plans
        many_to_many :services

        def before_destroy
          self.remove_all_product_features
          self.remove_all_services
          self.remove_all_plans
        end

      end

    end
  end
end
