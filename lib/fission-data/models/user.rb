require 'ostruct'
require 'fission-data'

module Fission
  module Data
    module Models

      # User data model
      class User < Sequel::Model

        # Preferred default identity
        DEFAULT_IDENTITY = 'github'

        one_to_one :active_session, :class => Session
        one_to_many :owned_accounts, :class => Account
        many_to_many :member_accounts, :class => Account, :right_key => :account_id, :join_table => 'accounts_members'
        many_to_many :managed_accounts, :class => Account, :right_key => :account_id, :join_table => 'accounts_owners'
        one_to_many :identities
        many_to_one :source
        one_to_many :tokens
        one_to_many :whitelists, :key => :creator_id

        # Create new instance
        # @note used for run_state initializaiton
        def initialize(*_)
          super
          @run_state = OpenStruct.new
        end

        # @return [Account] user specific account
        def base_account
          owned_accounts_dataset.where(:name => self.username).first
        end

        # @return [OpenStruct] instance cache data
        def run_state
          key = "#{self.name}_run_state".to_sym
          Thread.current[key] ||= OpenStruct.new
        end

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
          if(default_identity)
            default_identity[:infos][:email]
          end
        end

        # @return [Array<Permission>]
        def permissions
          [self.owned_accounts,
            self.member_accounts,
            self.managed_accounts
          ].flatten.compact.map(&:active_permissions).
            flatten.compact.uniq
        end

        # @return [Array<Account>] all accounts
        def accounts
          [self.owned_accounts,
            self.member_accounts,
            self.managed_accounts
          ].flatten.compact
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
          if(owned_accounts.empty?)
            source = Source.find_or_create(:name => 'internal')
            add_owned_account(
              :name => name || username,
              :source_id => source.id
            )
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
          self.active_session.data
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
