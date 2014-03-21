require 'fission-data'

module Fission
  module Data
    module Riak
      class Identity < ModelBase

        include Fission::Data::ModelInterface::Identity

        def before_create
          super
          self.provider_identity = [provider, uid].compact.join('_')
        end

        def after_create
          super
          user = self.user
          user.add_identities self
          user.save
        end

        if(defined?(::Rails))
          validates_confirmation_of :password
        end

        bucket :identities

        value :provider_identity, :class => String
        value :uid, :class => String
        value :provider, :class => String
        value :email, :class => String
        value :credentials, :class => Fission::Data::Hash, :default => Hash.new
        value :extras, :class => Fission::Data::Hash, :default => Hash.new
        value :infos, :class => Fission::Data::Hash, :default => Hash.new
        value :password_digest, :class => String

        link :user, User, :to => :identities, :dependent => true

        index :provider_identity, :unique => true

        class << self

          # uid:: User id
          # provider:: provider name
          # Return identity
          def lookup(uid, provider=nil)
            provider ||= 'internal'
            self.by_provider_identity(lookup_key(uid, provider))
          end

        end

      end
    end
    Identity = Riak::Identity
  end
end
