module Fission
  module Data
    module ModelInterface
      module InstanceMethods

        def to_s
          respond_to?(name) && name ? name : id
        end

        def display_links
          raise NotImplementedError
        end

      end
    end
  end
end
