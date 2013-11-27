require 'fission-data'

module Fission
  module Data
    module Utils

      module ValidationCompat
        class << self
          def included(klass)
            klass.class_eval do
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
