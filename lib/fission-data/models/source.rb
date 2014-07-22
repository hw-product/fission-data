require 'fission-data'

module Fission
  module Data
    module Models

      # Source container for models (origin of user and data)
      class Source < Sequel::Model

        one_to_many :users, :class => User
        one_to_many :accounts, :class => Account
        one_to_many :identities, :class => Identity

        # Validate instance attributes
        def validate
          super
          validates_presence :name
          validates_unique :name
        end

      end

    end
  end
end
