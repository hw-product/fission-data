require 'fission-data'

module Fission
  module Data
    module Riak
      class Tag < ModelBase

        include Fission::Data::ModelInterface::Tag

        bucket :tags

        value :name, :class => String

      end

    end
    Tag = Riak::Tag
  end
end
