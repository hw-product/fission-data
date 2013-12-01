require 'fission-data'

module Fission
  module Data

    class Repository < ModelBase

      bucket :repositories

      value :url, :class => String
      value :name, :class => String
      value :clone_url, :class => String
      value :private

      index :url, :unique => true
      index :clone_url, :unique => true

      link :owner, Account, :to => :repositories, :dependent => true

    end

  end
end
