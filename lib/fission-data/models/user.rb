require 'fission-data'

module Fission
  module Data
    module Models

      # User data model
      class User < Sequel::Model

        # Preferred default identity
        DEFAULT_IDENTITY = :github

        one_to_one :base_account, :class => Account
        one_to_many :accounts, :class => Account, :join_table => 'accounts_members'
        one_to_one :active_session, :class => Session
        many_to_many :managed_accounts, :class => Account, :right_key => :account_id, :join_table => 'accounts_owners'
        one_to_many :identities, :class => Identity
        many_to_one :source, :class => Source
        one_to_many :tokens, :class => Token

        # Validate instance attributes
        def validate
          super
          validates_presence :username
        end

        # Ensure our account wrapper is created
        def after_create
          super
          create_account
        end

        # @return [Identity]
        def default_identity
          identities_dataset.where(:provider => DEFAULT_IDENTITY).first ||
            identities.first
        end

        # @return [NilClass, String] email
        def email
          default_identity.infos[:email]
        end

        # @return [Array<Permission>]
        def permissions
          self.accounts.map(&:active_permissions)
        end

        # OAuth token for a provider
        #
        # @param provider [String]
        # @return [NilClass, String]
        def token_for(provider)
          ident = self.identities_dataset.where(:provider => provider).first
          if(ident)
            ident.credentials[:token]
          end
        end

        # Create an account and attach to this user
        #
        # @param name [String] account name
        # @return [Account]
        def create_account(name=nil)
          unless(base_account)
            act = Account.new(
              :name => name || username,
              :owner => self
            )
            source = Source.find_or_create(:name => 'internal')
            act.source = source
            if(act.save)
              self.base_account = act
              unless(self.save)
                raise self.errors
              end
            else
              raise "Failed to create base account"
            end
          end
        end

        # Session access wrapper
        #
        # @return [Session]
        def session
          unless(self.active_session)
            session = Session.create(:user => self, :data => {})
            self.reload
            self.save
          end
          self.active_session
        end

        # Reset the `session_data`
        #
        # @return [Session]
        def clear_session!
          current = self.active_session
          if(current)
            current.delete
          end
          self.session
        end

        class << self

          # Attempt to locate user and authenticate via password
          #
          # @param attributes [Hash]
          # @option attributes [String] :username
          # @option attributes [String] :password
          # @return [NilClass, User]
          def authenticate(attributes)
            ident = Identity.lookup(attributes[:username], :internal)
            if(ident && ident.authenticate(attributes[:password]))
              ident.user
            end
          end

          # Create a new user instance and new identity if required
          #
          # @param attributes [Hash] omniauth hash
          # @return [User]
          # @note refactor this. used mainly for password auth.
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

        end
      end
    end
  end
end
