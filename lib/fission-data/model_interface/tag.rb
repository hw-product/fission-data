module Fission
  module Data
    module ModelInterface

      module Tag

        class << self

          def included(klass)
            klass.class_eval do
              class << self
                def display_attributes
                  [:name]
                end
              end
            end
          end
        end

      end

    end
  end
end
