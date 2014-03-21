module Fission
  module Data
    module ModelInterface
      autoload :ClassMethods, 'fission-data/model_interface/class_methods'
      autoload :InstanceMethods, 'fission-data/model_interface/instance_methods'

      class << self

        def included(klass)
          klass.send(:include, InstanceMethods)
          klass.send(:extend, ClassMethods)
        end

      end

    end
  end
end
