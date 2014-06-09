require 'fission-data'

module Fission
  # Rails helper
  def use_relative_model_naming?; true; end
  module Data
    # Rails helper
    def use_relative_model_naming?; true; end
    module Utils
      # Rails naming helper module
      module NamingCompat
      end
    end
  end
end
