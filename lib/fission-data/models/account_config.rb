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
          validates_presence [:service_id, :account_id]
          validates_unique [:service_id, :account_id]
        end

        def before_save
          super
          self.data ||= {}
          self.data = Sequel.pg_json(self.data)
        end

        # @return [String]
        def service_name
          self.service.name
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
