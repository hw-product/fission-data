require 'fission-data'

module Fission
  module Data
    module Models

      # User account
      class Account < Sequel::Model

        many_to_one :owner, :class => User, :key => :user_id
        many_to_many :owners, :class => User, :right_key => :user_id, :join_table => 'accounts_owners'
        many_to_many :members, :class => User, :right_key => :user_id, :join_table => 'accounts_members'
        many_to_many :permissions
        one_to_many :jobs
        one_to_many :repositories
        one_to_many :tokens
        one_to_many :customer_payments
        one_to_many :logs
        one_to_many :account_configs
        one_to_many :custom_services
        many_to_one :source
        many_to_many :product_features
        one_to_many :routes

        def before_save
          super
          self.metadata ||= {}
          self.metadata = Sequel.pg_json(self.metadata)
        end

        # Scrub associations prior to destruction
        def before_destroy
          super
          self.remove_all_owners
          self.remove_all_members
          self.remove_all_account_configs
          self.delete_all_custom_services
        end

        # Validate account attributes
        def validate
          super
          validates_presence :name
        end

        # @return [String] source and account name composite
        def expanded_name
          [self.source.try(:name), self.name].join('_')
        end

        # Provides filtered list permission instances
        # that are active for account (filters based
        # on customer payment)
        #
        # @return [Array<Permission>]
        def active_permissions
          perms = self.permissions.find_all do |perm|
            if(perm.customer_validate)
              customer_payments.detect do |customer_payment|
                customer_payment.valid_permission?(perm)
              end
            else
              true
            end
          end + self.customer_payments.map(&:permission_list).map(&:all) +
            self.product_features.map(&:permissions)
          perms.flatten.compact.uniq
        end

        # @return [Array<Fission::Data::Models::ProductFeature>]
        def product_features
          (self.product_features_dataset.all +
            customer_payments.map(&:product_features).map(&:all)
          ).flatten.compact.uniq
        end

        # @return [Array<Fission::Data::Models::Service>]
        def services
          product_features.map(&:services).flatten.compact.uniq
        end

        # @return [Array<Fission::Data::Models::Product>]
        def products
          (product_features.map(&:product) +
            customer_payments.map(&:plans).map(&:product).compact).uniq
        end

        # User is owner of this account
        #
        # @param user [User]
        # @return [Truthy, Falsey]
        def owner?(user)
          user == owner || owners.include?(user)
        end

        # @return [Fission::Utils::Smash]
        def metadata
          unless(self.values[:metadata].is_a?(Smash))
            self.values[:metadata] = (self.values[:metadata] || {}).to_smash
          end
          self.values[:metadata]
        end

        # @return [CustomerPayment]
        def customer_payment
          self.customer_payments.first
        end

      end
    end
  end
end
