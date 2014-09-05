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
        one_to_many :jobs, :class => Job
        one_to_many :repositories, :class => Repository
        one_to_many :tokens, :class => Token
        one_to_many :customer_payments, :class => CustomerPayment
        one_to_many :logs
        many_to_one :source, :class => Source

        # Validate account attributes
        def validate
          super
          validates_presence :name
        end

        class << self

          # Lookup account instance
          #
          # @param name [String] account name
          # @param source [String] source name
          # @param args [Symbol] arugment list (:remote)
          # @return [NilClass, Fission::Data::Models::Account]
          # @note :remote option will attempt load from remote payment source
          def lookup(name, source, *args)
            source = Source.find_by_name(source)
            account = source.accounts_dataset.where(
              :name => name
            ).first
            if(account.nil? && args.include?(:remote))
              self.create(
                :name => name,
                :source_id => source.id
              )
              CustomerPayment.remote_load(account)
            end
            account
          end

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
          end + self.customer_payments.map(&:permission_list).map(&:all)
          perms.flatten.compact.uniq
        end

        # User is owner of this account
        #
        # @param user [User]
        # @return [Truthy, Falsey]
        def owner?(user)
          user == owner || owners.include?(user)
        end

      end
    end
  end
end
