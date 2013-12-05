require 'fission-data'

module Fission
  module Data


    class Account < ModelBase

      bucket :accounts

      value :name, :class => String
      value :source, :class => String
      value :name_source, :class => String
      value :stripe_id, :class => String
      value :subscription_id, :class => String
      value :subscription_expires, :class => DateTime

      index :name_source, :unique => true

      link :owner, User, :to => :base_account
      links :owners, User, :to => :managed_accounts
      links :members, User, :to => :accounts
      links :jobs, Job, :to => :account
      links :repositories, Repository, :to => :owner
      links :products, Product, :to => :enabled_accounts

      class << self
        def display_attributes
          [:name, :source, :owner]
        end

        def restrict(user)
          ([user.base_account] + user.accounts).compact.uniq
        end
      end

      def before_save
        super
        unless(name_source)
          name_source = "#{name}_#{source}"
        end
      end

      def to_s
        name
      end

    end

  end
end
