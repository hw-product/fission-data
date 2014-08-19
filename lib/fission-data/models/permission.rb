require 'fission-data'

module Fission
  module Data
    module Models

      # Permission model
      class Permission < Sequel::Model

        many_to_many :tokens
        many_to_many :accounts
        many_to_one :product

        # Validate instance attributes
        def validate
          super
          validates_presence [:name, :pattern]
          validates_unique :name
        end

        # @return [NilClass, Regexp]
        def pattern
          if(self[:pattern])
            Regexp.new(self[:pattern])
          end
        end

      end

    end
  end
end
