require 'fission-data'
require 'digest/sha2'

module Fission
  module Data
    module Riak
      class User < ModelBase

        include Fission::Data::ModelInterface::User

        bucket :users

        value :username
        value :name
        value :updated_at, :class => Time
        value :created_at, :class => Time
        value :permissions, :class => Array
        value :session_data, :class => Hash, :default => Hash

        index :username, :unique => true

        link :base_account, Account, :to => :owner
        link :active_session, Session, :to => :user
        links :managed_accounts, Account, :to => :owners
        links :accounts, Account, :to => :members
        links :identities, Identity, :to => :user, :dependent => true

      end

    end
    User = Riak::User
  end
end
