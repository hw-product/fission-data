module Fission
  module Data
    # Basic model interfaces.
    module ModelInterface

      Dir.new(File.join(File.dirname(__FILE__), 'model_interface')).each do |path|
        next if path.start_with?('.')
        klass = File.basename(path).sub(File.extname(path), '').split('_').map(&:capitalize).join.to_sym
        path = "fission-data/model_interface/#{File.basename(path).sub(File.extname(path), '')}"
        autoload klass, path
      end

      class << self

        # Inject methods into class when included
        #
        # @param klass [Class]
        def included(klass)
          klass.class_eval do

            # @return [String]
            def to_s
              respond_to?(name) && name ? name : id
            end

            # @return [Array<String,Symbol>] links to display
            def display_links
              raise NotImplementedError
            end

            class << self

              # @return [Array<String,Symbol>] attributes of model
              def attribute_names
                raise NotImplementedError
              end

              # @return [Array<String,Symbol>] attributes to display
              def display_attributes
                raise NotImplementedError
              end

              # @return [Array<String,Symbol>] links to display
              def display_links
                raise NotImplementedError
              end

              # Filter items based on user
              #
              # @param user [Fission::Data::User]
              # @return [Dataset]
              def restrict(user)
                raise NotImplementedError
              end

              # Generate a source key
              #
              # @param args [Object] argument list
              # @return [String] argument list stringed and joined
              def source_key(*args)
                args.compact.map(&:to_s).join('_')
              end

              # @return [Array] link associations
              def link_associations
              end

              # Allow find by attribute name searching
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
    end
  end
end
