require 'fission-data'

module Fission
  module Data


    class Account < ModelBase

      bucket :accounts

      value :name, :class => String
      value :email, :class => String
      value :source, :class => String
      value :name_source, :class => String
      value :stripe_id, :class => String
      value :subscription_id, :class => String
      value :subscription_expires, :class => DateTime

      index :name
      index :name_source, :unique => true

      link :owner, User, :to => :base_account
      links :owners, User, :to => :managed_accounts
      links :members, User, :to => :accounts
      links :jobs, Job, :to => :account
      links :repositories, Repository, :to => :owner
      links :products, Product, :to => :enabled_accounts


      class << self

        # name:: Account name
        # source:: Source of account
        # Find the given account
        def lookup(name, source)
          find_by_name_source(source_key(name, source))
        end

        # Attributes to display by default
        def display_attributes
          [:name, :source, :owner]
        end

        # user:: Fission::Data::User instance
        # Only show user accounts they own
        def restrict(user)
          ([user.base_account] + user.accounts + user.managed_accounts).compact.uniq
        end

      end

      # Ensure `name_source` is set
      def before_save
        super
        self.name_source = self.class.source_key(name, source)
      end

      # Look pretty in strings
      def to_s
        name
      end

      # Return if account has subscription
      def subscribed?
        !!subscription_id
      end

      # Return if subscription is expired
      def expired?
        if(subscription_expires)
          subscription_expires < Time.now
        end
      end

      # user:: Fission::Data::Instance
      # Return if user is valid owner of this account
      def owner?(user)
        user == owner || owners.include?(user)
      end

      # Restrict link display based on user status
      def display_links(user)
        if(owner?(user))
          super
        else
          []
        end
      end

    end

  end
end
