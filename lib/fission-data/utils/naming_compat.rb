require 'fission-data'

module Fission
  def use_relative_model_naming?; true; end
  module Data
    def use_relative_model_naming?; true; end
    module Utils
      module NamingCompat
      end
    end
  end
end
