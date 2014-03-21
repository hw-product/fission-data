require 'fission-data'

module Fission
  module Data
    module Riak
      class Repository < ModelBase

        include Fission::Data::ModelInterface::Repository

        bucket :repositories

        value :url, :class => String
        value :name, :class => String
        value :source, :class => String
        value :name_source, :class => String
        value :clone_url, :class => String
        value :metadata, :class => Hash, :default => Hash.new
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

          def restrict(user)
            repos = user.managed_accounts.map do |acct|
              acct.repositories
            end + user.base_account.repositories
            repos.flatten.compact
          end

        end

        def before_save
          super
          self.name_source = self.class.source_key(name, source)
        end

      end

    end
    Repository = Riak::Repository
  end
end
