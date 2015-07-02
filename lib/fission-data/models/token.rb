require 'fission-data'
require 'securerandom'
require 'digest'


module Fission
  module Data
    module Models

      # Authentication tokens
      class Token < Sequel::Model

        many_to_one :user
        many_to_one :account
        many_to_many :permissions

        # Auto generate token value
        def before_save
          super
          unless(self[:token])
            self[:token] = Digest::SHA256.hexdigest(
              SecureRandom.random_bytes
            )
          end
          validates_presence [:token, :name]
          validates_unique :token
          validates_unique [:name, :account_id, :user_id]
        end

      end

    end
  end
end
