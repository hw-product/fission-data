require 'fission-data'

module Fission
  module Data
    module Models

      # Specialized account configurations
      class AccountConfig < Sequel::Model

        many_to_one :account
        many_to_one :service

        # Validate instance attributes
        def validate
          super
          validates_presence [:name, :account_id]
          validates_unique [:name, :account_id]
        end

        def before_save
          super
          self.data ||= {}
          self.data = Sequel.pg_json(self.data)
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
