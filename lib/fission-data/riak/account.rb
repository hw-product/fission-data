require 'fission-data'

module Fission
  module Data
    module Riak
      class Account < ModelBase

        include Fission::Data::ModelInterface::Account

        bucket :accounts

        value :name, :class => String
        value :email, :class => String
        value :source, :class => String
        value :name_source, :class => String
        value :stripe_id, :class => String
        value :subscription_id, :class => String
        value :subscription_plan_id, :class => String
        value :subscription_expires, :class => Fixnum

        index :name
        index :name_source, :unique => true

        link :owner, User, :to => :base_account
        links :owners, User, :to => :managed_accounts
        links :members, User, :to => :accounts
        links :jobs, Job, :to => :account
        links :repositories, Repository, :to => :owner
        links :products, Product, :to => :enabled_accounts
        links :tokens, Token, :to => :account

        class << self

          def restrict(user)
            ([user.base_account] + [user.managed_accounts]).flatten.compact.uniq.sort_by(&:name)
          end

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
            account = self.new(
              :name => name,
              :source => source.to_s
            )
            account.set_payment_information if customer
            account
          end

          # Detect existing stripe customer instance for this account
          def find_stripe_customer(account_name)
            if(account_name)
              if(defined?(Stripe))
                unless(@retrieved)
                  @retrieved = Stripe::Customer.all.to_a
                  # TODO: looping gets us a weird threading error
=begin
                     until((customers = Stripe::Customer.all(:offset => retrieved.size)).count < 1)
                       @retrieved += customers.to_a
                     end
=end
                end
                @retrieved.detect do |customer|
                  customer.metadata[:fission_account_name] == account_name
                end
              end
            end
          end

        end

        # Ensure `name_source` is set
        def before_save
          super
          self.name_source = self.class.source_key(name, source)
        end

        # Updates payment information from remote payment data
        def set_payment_information
          customer = payment_account
          if(customer)
            self.stripe_id = customer.id
            if(customer.subscription)
              self.subscription_id = customer.subscription.id
              self.subscription_plan_id = customer.subscription.plan.id
              self.subscription_expires = customer.subscription.current_period_end
            end
            true
          else
            false
          end
        end

        def create_token
          token = Token.new
          token.account = self
          token.save
          token
        end

      end

    end
    Account = Riak::Account
  end
end
