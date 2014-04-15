module Fission
  module Data
    module ModelInterface

      Dir.new(File.join(File.dirname(__FILE__), 'model_interface')).each do |path|
        next if path.start_with?('.')
        klass = File.basename(path).sub(File.extname(path), '').split('_').map(&:capitalize).join.to_sym
        path = "fission-data/model_interface/#{File.basename(path).sub(File.extname(path), '')}"
        autoload klass, path
      end

      class << self

        def included(klass)
          klass.class_eval do

            def to_s
              respond_to?(name) && name ? name : id
            end

            def display_links
              raise NotImplementedError
            end

            class << self
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
    end
  end
end
