module Fission
  module Data
    module ModelInterface

      module Account

        module ClassMethods
          def display_attributes
            [:name, :source, :owner]
          end

          def restrict(user)
            ([user.base_account] + user.managed_accounts).compact.uniq
          end

          def find_stripe_customer(account_name)
            if(account_name)
              if(defined?(Stripe))
                unless(@retrieved)
                  @retrieved = []
                  until((customers = Stripe::Customer.all(:offset => @retrieved.size)).count < 1)
                    @retrieved += customers.to_a
                  end
                end
                @retrieved.detect do |customer|
                  customer.metadata[:fission_account_name] = account_name
                end
              end
            end
          end

        end

        module InstanceMethods

          # Return if account has subscription
          def subscribed?
            !!subscription_id
          end

          # Return if subscription is expired
          def expired?
            if(subscription_expires)
              subscription_expires < Time.now.to_i
            end
          end

          # Return if account is active (valid subscription)
          def active?
            subscribed? && !expired?
          end

          # user:: Fission::Data::Instance
          # Return if user is valid owner of this account
          def owner?(user)
            user == owner || owners.include?(user)
          end

          # Return a valid github access token of an owner
          def github_token
            user = self.owner || self.owners.first
            user.identities.detect do |identity|
              identity.provider.to_sym == :github
            end.credentials['token']
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

        class << self

          def included(klass)
            klass.class_eval do
              include Fission::Data::Sql::InstanceMethods
              extend Fission::Data::Sql::ClassMethods
              include InstanceMethods
              extend ClassMethods
            end
          end

        end

      end

    end
  end
end
