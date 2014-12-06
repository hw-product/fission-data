require 'fission-data'
require 'securerandom'

module Fission
  module Data
    module Models
      # User identity
      class Identity < Sequel::Model

        # @return [String] user password
        attr_accessor :password
        # @return [String] user password confirmation
        attr_accessor :password_confirmation

        # Default salter
        SALTER = 'fission-data-salter-00220'
        # Default salt joiner
        SALTER_JOINER = '~~*~~'

        self.add_pg_typecast_on_load_columns :extras, :infos

        many_to_one :source, :class => Source
        many_to_one :user, :class => User

        # Validate instance attributes
        def validate
          super
          validates_presence [:uid, :user_id]
        end

        # Apply filter to attributes prior to save
        def before_save
          super
          unless(self.values[:credentials])
            self.values[:credentials] = {}
          end
          random_sec = 3.times.map{ SecureRandom.urlsafe_base64 }.join
          self.user.run_state.random_sec = random_sec
          self.credentials = Utils::Cipher.encrypt(
            JSON.dump(self[:credentials]),
            :key => [SALTER, self.user.username, self.user.run_state.random_sec].join(SALTER_JOINER),
            :iv => self.user.run_state.random_sec
          )
          self.extras = Sequel.pg_json(self.extras)
          self.infos = Sequel.pg_json(self.infos)
          if(password)
            self.password_digest = checksum(password)
          end
        end

        # @return [Fission::Utils::Smash]
        def extras
          unless(self.values[:extras].is_a?(Smash))
            self.values[:extras] = (self.values[:extras] || {}).to_smash
          end
          self.values[:extras]
        end

        # @return [Fission::Utils::Smash]
        def infos
          unless(self.values[:infos].is_a?(Smash))
            self.values[:infos] = (self.values[:infos] || {}).to_smash
          end
          self.values[:infos]
        end

        # @return [Fission::Utils::Smash] credentials
        def credentials
          begin
            res = Smash.new(
              JSON.load(
                Utils::Cipher.decrypt(
                  self.values[:credentials],
                  :key => [
                    SALTER, self.user.username, self.user.run_state.random_sec
                  ].join(SALTER_JOINER),
                  :iv => self.user.run_state.random_sec
                )
              )
            )
            res
          rescue => e
            Rails.logger.warn "Failed loading credentials. #{e.class}: #{e}"
            nil
          end
        end

        # Provider specific identity. This is a combination of
        # remote source and uid
        #
        # @return [String]
        def provider_identity
          [self.source.name, self.uid].compact.join('_')
        end

        # Authenticate user via password
        #
        # @param auth_password [String] challenge password
        # @return [TrueClass, FalseClass]
        def authenticate(auth_password)
          if(password_digest)
            password_digest == checksum(auth_password)
          else
            false
          end
        end

        protected

        # string:: String
        # Return salted checksum of string
        def checksum(string)
          Digest::SHA512.hexdigest([SALTER, string].join(SALTER_JOINER))
        end

        class << self

          # Lookup user by UID filtered by a source
          #
          # @param uid [String]
          # @param source_name [String]
          # @return [NilClass, User]
          def lookup(uid, source_name=nil)
            source = Source.find_by_name(source_name || 'internal')
            if(source)
              source.identities_dataset.where(:uid => uid).first
            end
          end

          # uid:: User id
          # provider:: provider name
          # Returns lookup key
          def lookup_key(uid, provider=nil)
            [provider, uid].compact.join('_').to_sym
          end

          # Find existing identity or create new
          #
          # @param attributes [Hash] omniauth hash
          # @return [Identity]
          def find_or_create_via_omniauth(attributes, existing_user=nil)
            identity = lookup(attributes[:uid], attributes[:provider])
            if(identity)
              Fission::Data.logger.info "Found existing identity: #{identity.inspect}"
            else
              Fission::Data.logger.info "No existing identity found! Creating new user: #{attributes[:uid]}"
              source = Source.find_or_create(:name => attributes[:provider])
              username = attributes[:info].try(:[], :nickname) ||
                attributes[:info].try(:[], :login) ||
                attributes[:info].try(:[], :email) ||
                unique_id
              user = User.find_by_username(username)
              unless(user)
                user = User.new(:username => username)
                user.run_state.identity_provider = attributes[:provider]
                user.source = source if source
                user.save
              end
              identity = Identity.new
              identity.user = user
            end
            identity.provider = attributes[:provider]
            identity.uid = attributes[:uid]
            identity.extras = attributes[:extras]
            identity.credentials = attributes[:credentials]
            identity.infos = attributes[:info]
            identity.source = source if source
            # Set login time
            identity.user.session[:login_time] = Time.now.to_f
            identity.user.save_session
            unless(identity.save)
              Fission::Data.logger.error identity.errors.inspect
              raise identity.errors unless identity.save
            end
            identity
          end

        end

      end
    end
  end
end
