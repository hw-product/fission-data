require 'fission-data'

module Fission
  module Data
    module Models

      # Custom fission source (webhook)
      class CustomService < Sequel::Model

        many_to_one :account
        many_to_many :routes

        def before_destroy
          super
          self.remove_all_routes
        end

        def validate
          super
          validates_presence :name
          validates_presence :endpoint
          validates_presence :account_id
          validates_unique [:name, :account_id]
        end

      end

    end
  end
end
