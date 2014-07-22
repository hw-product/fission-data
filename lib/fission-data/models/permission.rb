require 'fission-data'

module Fission
  module Data
    module Models

      # Permission model
      class Permission < Sequel::Model

        many_to_many :tokens
        many_to_many :accounts

        # Validate instance attributes
        def validate
          super
          validates_presence [:name, :pattern]
          validates_uniqueness :name
        end

        # @return [Array<Regexp>]
        def permissions
          self[:permissions].map do |perm_string|
            Regexp.new(perm_string)
          end
        end

      end

    end
  end
end
