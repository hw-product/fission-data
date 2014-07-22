require 'fission-data'

module Fission
  module Data
    module Models

      # User session data
      class Session < Sequel::Model

        many_to_one :user, :class => User

        self.add_pg_typecast_on_load_columns :data

        # Validate instance attributes
        def validate
          super
          validates_presence :user_id
        end

        # Format instance attributes before save
        def before_save
          super
          self.data = Sequel.pg_json(self.data)
        end

        # Fetch value from data
        #
        # @param args [String, Symbol]
        # @return [Object]
        def get(*args)
          self.data.get(*args)
        end

        # Set value into data
        #
        # @param args [String, Symbol, Object]
        # @return [Object]
        def set(*args)
          self.data.set(*args)
        end

      end

    end
  end
end
