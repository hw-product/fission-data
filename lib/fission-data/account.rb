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
        # args:: options
        # Find the given account. If `*args` includes `:remote`
        # account discovery will be attempted via payment api lookup
        # NOTE: If account is created from remote data it will not be
        # saved prior to return
        def lookup(name, source, *args)
          account = find_by_name_source(source_key(name, source))
          unless(account)
            account = remote_lookup(name, source) if args.include?(:remote)
          end
          account
        end

        # name:: Account name
        # source:: Source of account
        # Returns new account instance based on remote data lookup
        # NOTE: Returned account will be an unsaved instance
        def remote_lookup(name, source)
          customer = find_stripe_customer(source_key(name, source))
          if(customer)
            account = self.new(
              :name => name,
              :source => source.to_s
            )
            account.set_payment_information
            account
          end
        end

        # Attributes to display by default
        def display_attributes
          [:name, :source, :owner]
        end

        # user:: Fission::Data::User instance
        # Only show user accounts they own
        def restrict(user)
          ([user.base_account] + user.managed_accounts).compact.uniq
        end

        # Detect existing stripe customer instance for this account
        def find_stripe_customer(account_name)
          if(defined?(Stripe))
            unless(@retrieved)
              retrieved = []
              until((customers = Stripe::Customer.all(:offset => retrieved.size)).empty?)
                retrieved += customers
              end
            end
            @retrieved.detect do |customer|
              customer.metadata.fission_account_name == account_name
            end
          end
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

      # Return if account is active (valid subscription)
      def active?
        subscribed? && !expired
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

      # Updates payment information from remote payment data
      def set_payment_information
        customer = payment_account
        if(customer)
          self.stripe_id = customer.id
          if(customer.subscription)
            self.subscription_id = customer.subscription.id
            self.subscription_expires = Time.at(customer.subscription.current_period_end).to_datatime
          end
          true
        else
          false
        end
      end

      # Return payment object linked to this account
      def payment_account
        if(defined?(Stripe))
          if(self.stripe_id)
            Stripe::Customer.retrieve(self.stripe_id)
          else
            self.class.find_stripe_customer(self.name_source)
          end
        end
      end

    end

  end
end
