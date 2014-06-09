module Fission
  module Data
    module ModelInterface

      module Log

        class << self

          def included(klass)
            klass.class_eval do
              class << self
                def display_attributes
                  [:source, :path]
                end

                def restrict(user)
                  # only against accts accessible
                  Fission::Data::Log.dataset
                end

              end
            end
          end
        end

      end

    end
  end
end
