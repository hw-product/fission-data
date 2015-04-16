require 'fission-data'

module Fission
  module Data
    module Models

      # Specialized account configurations
      class AccountConfig < Sequel::Model

        many_to_one :account

        # Validate instance attributes
        def validate
          super
          validates_presence [:service_name, :data, :account_id]
          validates_unique [:service_name, :account_id]
        end

        def before_save
          super
          self.extras ||= {}
          self.extras = Sequel.pg_json(self.extras)
        end

        # @return [Fission::Utils::Smash]
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
