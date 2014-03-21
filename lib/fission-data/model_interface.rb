module Fission
  module Data
    module ModelInterface

      Dir.glob(File.join(File.dirname(__FILE__), 'model_interface', '*')).each do |path|
        klass = File.basename(path).sub(File.extname(path), '').split('_').map(&:capitalize).join.to_sym
        path = "fission-data/model_interface/#{File.basename(path)}"
        autoload klass, path
      end

    end
  end
end
