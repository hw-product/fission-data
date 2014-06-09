require 'fission-data'

module Fission
  module Data
    module Utils

      # Rails validation helper
      module ValidationCompat
        class << self
          # Load valid helper
          #
          # @param klass [Class]
          def included(klass)
            klass.class_eval do
              # @return [Truthy, Falsey] validity
              def valid?
                super
                elder = self.class.superclass
                orig_valid = elder.instance_method(:valid?)
                orig_valid.bind(self).call
              end
            end
          end
        end
      end

    end
  end
end
