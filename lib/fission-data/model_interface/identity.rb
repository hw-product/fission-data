module Fission
  module Data
    module ModelInterface

      module Identity

        module ClassMethods

          # uid:: User id
          # provider:: provider name
          # Returns lookup key
          def lookup_key(uid, provider=nil)
            [provider, uid].compact.join('_').to_sym
          end

          # attributes:: attribute hash
          # Find existing identity or create new based on provided attributes
          def find_or_create_via_omniauth(attributes, existing_user=nil)
            identity = lookup(attributes[:uid], attributes[:provider])
            if(identity)
              Rails.logger.info "Found existing identity: #{identity.inspect}"
            else
              Rails.logger.info "No existing identity found! Creating new user"
              username = attributes[:info].try(:[], :nickname) ||
                attributes[:info].try(:[], :login) ||
                attributes[:info].try(:[], :email) ||
                unique_id
              user = User.by_username(username)
              if(user)
                raise 'User exists. Where is ident!?'
              else
                user = User.create(:username => username)
                if(user)
                  identity = Identity.new
                  identity.provider = attributes[:provider]
                  identity.uid = attributes[:uid]
                  identity.extras = attributes[:extras]
                  identity.credentials = attributes[:credentials]
                  identity.infos = attributes[:info]
                  identity.user = user
                  unless(identity.save)
                    Rails.logger.error identity.errors.inspect
                    raise identity.errors unless identity.save
                  end
                else
                  raise "Failed to create user!"
                end
              end
            end
            identity
          end

        end

        module InstanceMethods

          def before_save
            super
            if(password)
              self.password_digest = checksum(password)
            end
          end

          def authenticate(auth_password)
            if(password_digest)
              password_digest == checksum(auth_password)
            end
          end

          protected

          # string:: String
          # Return salted checksum of string
          def checksum(string)
            Digest::SHA512.hexdigest("#{SALT}_#{string}")
          end

        end

        class << self

          def included(klass)
            klass.class_eval do
              include Fission::Data::Sql::InstanceMethods
              extend Fission::Data::Sql::ClassMethods
              include InstanceMethods
              extend ClassMethods

              SALT = 'fission01'
              attr_accessor :password, :password_confirmation
            end
          end

        end

      end

    end
  end
end
