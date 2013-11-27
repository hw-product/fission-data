require 'fission-data'

module Fission
  module Data

    class Repository < ModelBase

      bucket :repositories

      value :url, :class => String
      value :name, :class => String
      value :oauth_token, :class => String

      index :url, :unique => true

      link :owner, Account, :to => :repositories, :dependent => true

    end

  end
end
