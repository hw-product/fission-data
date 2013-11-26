require 'fission-data/model_base'

class Identity < ModelBase

  include ::OmniAuth::Identity::Model
  include ::OmniAuth::Identity::SecurePassword

  has_secure_password

  def before_create
    values[:provider_identity] = [values[:provider], values[:uid]].compact.join('_')
  end

  def after_create
    u = self.user
    u.add_identities self
    u.save
  end

  bucket :identities

  value :provider_identity, :class => String
  value :uid, :class => String
  value :provider, :class => String
  value :email, :class => String
  value :credentials, :class => Fission::Data::Hash, :default => {}.with_indifferent_access
  value :extras, :class => Fission::Data::Hash, :default => {}.with_indifferent_access
  value :infos, :class => Fission::Data::Hash, :default => {}.with_indifferent_access
  value :password_digest, :class => String

  attr_accessor :password_confirmation

  link :user, User, :to => :identities, :dependent => true

  index :provider_identity, :unique => true

  class << self

    def lookup_key(uid, provider=nil)
      [provider, uid].compact.join('_').to_sym
    end

    def lookup(uid, provider=nil)
      provider ||= 'fission'
      self.by_provider_identity(lookup_key(uid, provider))
    end

    def locate(search_hash)
      lookup(search_hash[:uid], search_hash[:provider])
    end

    def find_or_create_via_omniauth(attributes, existing_user=nil)
      provider = attributes[:provider] || 'fission'
      unique_id = attributes[:uid] || attributes[:unique_id]
      identity = lookup(unique_id, provider)
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
          identity = Identity.create(
            attributes.merge(
              :username => username,
              :unique_id => unique_id,
            )
          )
          identity.extras = attributes[:extras]
          identity.credentials = attributes[:credentials]
          identity.infos = attributes[:info]
          identity.provider = provider
          identity.uid = unique_id
          identity.password = attributes[:password]
          identity.password_confirmation = attributes[:password_confirmation]
          unless(identity.save)
            Rails.logger.error identity.errors.inspect
            raise identity.errors unless identity.save
          end
        end
      end
      identity
    end

    def create(attributes)
      username = attributes[:username] || attributes[:unique_id]
      user = User.by_username(username)
      unless(user)
        user = User.new
        user.username = username
        user.save
        user.create_account
      end

      ident_key = lookup_key(attributes[:unique_id], 'fission')
      identity = Identity.by_provider_identity(ident_key)
      unless(identity)
        identity = Identity.new
        identity.provider_identity = lookup_key(attributes[:unique_id], 'fission')
        identity.password = attributes[:password]
        identity.password_confirmation = attributes[:password_confirmation]
        identity.email = attributes[:email]
        identity.uid = attributes[:unique_id]
        identity.user = user
        unless(identity.save)
          Rails.logger.error identity.errors.inspect
          raise identity.errors
        end
      end
      identity
    end

  end

end
