module Fission
  module Data
    module ModelInterface

      Dir.new(File.join(File.dirname(__FILE__), 'model_interface')).each do |path|
        klass = File.basename(path).sub(File.extname(path), '').split('_').map(&:capitalize).join.to_sym
        path = "fission-data/model_interface/#{File.basename(path).sub(File.extname(path), '')}"
        autoload klass, path
      end

      class << self

        def included(klass)
          klass.send(:include, InstanceMethods)
          klass.send(:extend, ClassMethods)
        end

      end
    end
  end
end
