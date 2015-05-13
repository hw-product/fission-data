require 'fission-data'

module Fission
  module Data
    module Models
      # Plan metadata for UI display
      class Plan < Sequel::Model

        many_to_many :prices

        def before_destroy
          super
          self.prices.map(&:destroy)
        end

        def validate
          super
          validates_presence :remote_id
          validates_unique :remote_id
        end

      end

    end
  end
end
