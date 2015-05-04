require 'fission-data'

module Fission
  module Data
    module Models

      # Backend service configurable item
      class ServiceConfigItem < Sequel::Model

        many_to_one :service

        # Validate account attributes
        def validate
          super
          validates_presence :name
          validates_presence :service_id
          validates_unique [:name, :service_id]
        end

        def before_destroy
          super
        end

      end
    end
  end
end
