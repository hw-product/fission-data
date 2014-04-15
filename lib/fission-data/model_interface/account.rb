module Fission
  module Data
    module ModelInterface

      module Account

        class << self

          def included(klass)
            klass.class_eval do
              class << self
                def display_attributes
                  [:name, :source, :owner]
                end

                def restrict(user)
                  ([user.base_account] + user.managed_accounts).compact.uniq
                end

                def find_stripe_customer(account_name)
                  if(account_name)
                    if(defined?(::Stripe))
                      unless(@retrieved)
                        @retrieved = ::Stripe::Customer.all.to_a
                        # TODO: looping gets us a weird threading error
=begin
                           @retrieved = []
                           until((customers = ::Stripe::Customer.all(:offset => @retrieved.size)).count < 1)
                             @retrieved += customers.to_a
                           end
=end
                      end
                      @retrieved.detect do |customer|
                        customer.metadata[:fission_account_name] = account_name
                      end
                    end
                  end
                end

              end

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

              # Return payment object linked to this account
              def payment_account
                if(defined?(::Stripe))
                  if(self.stripe_id)
                    ::Stripe::Customer.retrieve(self.stripe_id)
                  else
                    ns = self.name_source || self.class.source_key(name, source)
                    self.class.find_stripe_customer(ns)
                  end
                end
              end

            end

          end

        end

      end

    end
  end
end
