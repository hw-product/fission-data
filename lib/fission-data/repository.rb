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
          self.metadata = {}
        end
        val = args.pop
        last_key = args.pop
        base = args.inject(self.metadata) do |memo, key|
          key = key.to_s
          unless(memo[key])
            memo[key] = {}
          end
          memo[key]
        end
        base[last_key] = val
      end

      # args:: keys to walk
      # Return value at end of path
      def get_metadata(*args)
        if(self.metadata)
          args.inject(self.metadata) do |memo, key|
            key = key.to_s
            memo[key] ? memo[key] : break
          end
        end
      end

    end

  end
end
