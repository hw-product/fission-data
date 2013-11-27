require 'fission-data'
require 'digest/sha2'

module Fission
  module Data

    class User < ModelBase

      class << self

        # List displayable attributes
        def display_attributes
          [:username, :name]
        end

        # attributes:: Attribute hash
        # Create a new user instance and identity instance if applicable
        def create(attributes)
          user = new(:username => attributes[:username])
          if(user.save)
            if(attributes[:provider] == :internal)
              identity = Identity.new(
                :uid => attributes[:username],
                :email => attributes[:email],
                :provider => :internal
              )
              identity.password = attributes[:password]
              identity.password_confirmation = attributes[:password_confirmation]
              identity.user = user
              if(identity.save)
                user.reload
                user
              else
                raise 'creation failed!'
              end
            end
            user
          else
            false
          end
        end

        # attributes:: Attribute hash including `:username` and `:password`
        # Attempt to locate user and authenticate
        def authenticate(attributes)
          ident = Identity.lookup(attributes[:username], :internal)
          if(ident && ident.authenticate(attributes[:password]))
            ident.user
          end
        end

      end

      bucket :users

      value :username
      value :name
      value :updated_at, :class => Time
      value :created_at, :class => Time
      value :permissions, :class => Array

      index :username, :unique => true

      link :base_account, Account, :to => :owner
      links :accounts, Account, :to => :members
      links :identities, Identity, :to => :user, :dependent => true

      def after_create
        super
        create_account
      end

      # name:: Optional account name (probably not needed until custom accounts can be created)
      # Create an account and attach it to this user as the base account
      def create_account(name=nil)
        unless(base_account)
          act = Account.new(
            :name => name || username,
            :owner => self
          )
          if(act.save)
            self.base_account = act
            unless(self.save)
              Rails.logger.error self.errors.inspect
              raise self.errors
            end
          else
            raise "Failed to create base account"
          end
        end
      end

      # Return nice looking string (just the username)
      def to_s
        username
      end

      # Check if user is permitted (not fully implemented yet)
      def permitted?(*args)
        args.detect do |permission|
          permissions.include?(permission)
        end
      end

    end

  end
end
