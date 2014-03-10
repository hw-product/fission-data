require 'multi_json'

module Fission
  module Data
    module Sql

      [:timestamps, :dirty, :pg_typecast_on_load, :validation_helpers].each do |plugin_name|
        Sequel::Model.plugin plugin_name
      end

      class BaseModel < Sequel::Model
      end

    end
    BaseModel = Sql::BaseModel
  end
end
