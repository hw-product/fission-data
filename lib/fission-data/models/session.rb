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

        # @return [Smash]
        def data
          unless(self.values[:data].is_a?(Smash))
            self.values[:data] = (self.values[:data] || {}).to_smash
          end
          self.values[:data]
        end

      end

    end
  end
end
