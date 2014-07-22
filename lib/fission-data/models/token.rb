require 'fission-data'

module Fission
  module Data
    module Models

      # Authentication tokens
      class Token < Sequel::Model

        many_to_one :user, :class => User
        many_to_one :account, :class => Account
        many_to_many :permissions, :class => Permission, :right_key => :permission_id, :join_table => 'permissions_tokens'

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
