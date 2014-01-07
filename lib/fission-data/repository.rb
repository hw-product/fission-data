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
      value :metadata, :class => Hash, :default => {}
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

        def restrict(user)
          repos = user.managed_accounts.map do |acct|
            acct.repositories
          end + user.base_account.repositories
          repos.flatten.compact
        end
      end

      # Return short name if long name
      def short_name
        name.split('/').last
      end

      # args:: keys to walk. Last arg is value
      # Set value into metadata hash
      def set_metadata(*args)
        unless(self.metadata)
          self.metadata = Fission::Data::Hash.new
        end
        Fission::Data::Hash.walk_set(self.metadata, *args)
      end

      # args:: keys to walk
      # Return value at end of path
      def get_metadata(*args)
        if(self.metadata)
          Fission::Data::Hash.walk_get(self.metadata, *args)
        end
      end

    end

  end
end
