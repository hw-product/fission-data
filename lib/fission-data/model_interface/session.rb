module Fission
  module Data
    module ModelInterface

      module Session

        module ClassMethods
        end

        module InstanceMethods

          # keys_and_value:: keys to walk. Last arg is value
          # Set value into session_data hash
          def put(*keys_and_value)
            result = Fission::Data::Hash.walk_set(self.data.to_hash, *keys_and_value)
            self.save
            result
          end

          # keys:: keys to walk
          # Return value at end of path
          def get(*keys)
            Fission::Data::Hash.walk_get(self.data.to_hash, *keys)
          end

        end

        class << self

          def included(klass)
            klass.class_eval do
              include InstanceMethods
              extend ClassMethods
            end
          end

        end

      end

    end
  end
end
