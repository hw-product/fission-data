require 'fission-data'

module Fission
  module Data

    class Repository < ModelBase

      bucket :repositories

      value :url, :class => String
      value :name, :class => String
      value :source, :class => String
      value :name_source, :class => String
      value :clone_url, :class => String
      value :private

      index :name
      index :name_source, :unique => true
      index :url, :unique => true
      index :clone_url, :unique => true

      link :owner, Account, :to => :repositories, :dependent => true

      class << self

        # name:: Repository name
        # source:: Source of account
        # Find the given account
        def lookup(name, source)
          find_by_name_source(source_key(name, source))
        end

        # List displayable attributes
        def display_attributes
          [:name, :url, :private]
        end
      end

      # Return short name if long name
      def short_name
        name.split('/').last
      end

    end

  end
end
