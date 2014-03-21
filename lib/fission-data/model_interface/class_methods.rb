module Fission
  module Data
    module ModelInterface
      module ClassMethods

        def attribute_names
          raise NotImplementedError
        end

        def display_attributes
          raise NotImplementedError
        end

        def display_links
          raise NotImplementedError
        end

        def restrict(user)
          raise NotImplementedError
        end

        def source_key(*args)
          args.compact.map(&:to_s).join('_')
        end

        def link_associations
        end

        def method_missing(*args)
          if(args.first.to_s.start_with?('find_by'))
            raise NotImplementedError
          else
            super
          end
        end

      end
    end
  end
end
