require 'fission-data'

module Fission
  module Data
    module Models

      # Authentication tokens
      class Token < Sequel::Model

        many_to_one :user
        many_to_one :account
        many_to_many :permissions

        # Validate instance attributes
        def validate
          super
          validates_presence :token
          validates_unique :token
        end

      end

    end
  end
end
