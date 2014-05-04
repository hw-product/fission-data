module Fission
  module Data
    module ModelInterface

      module Identity

        class << self

          def included(klass)
            klass.send(:const_set, :SALT, 'fission01')
            klass.class_eval do

              attr_accessor :password, :password_confirmation

              class << self
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
                    if(defined?(Fission::Data::Source))
                      source = Fission::Data::Source.find_or_create(:name => attributes[:provider])
                    end
                    username = attributes[:info].try(:[], :nickname) ||
                      attributes[:info].try(:[], :login) ||
                      attributes[:info].try(:[], :email) ||
                      unique_id
                    user = Fission::Data::User.find_by_username(username)
                    unless(user)
                      user = Fission::Data::User.new(:username => username)
                      user.source = source if source
                      user.save
                    end
                    identity = Fission::Data::Identity.new
                    identity.user = user
                  end
                end
                identity.provider = attributes[:provider]
                identity.uid = attributes[:uid]
                identity.extras = attributes[:extras]
                identity.credentials = attributes[:credentials]
                identity.infos = attributes[:info]
                identity.source = source if source

                # Set login time
                identity.user.session.put(:login_time => Time.now.to_f)
                unless(identity.save)
                  Rails.logger.error identity.errors.inspect
                  raise identity.errors unless identity.save
                end
                identity
              end

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

          end

        end

      end

    end
  end
end
