require 'digest/sha1'
require 'fission-data'

module Fission
  module Data
    module Riak
      class Token < ModelBase

        include Fission::Data::ModelInterface::Token

        bucket :tokens

        value :token, :class => String, :default => Digest::SHA1.hexdigest([Time.now.to_f, rand].join)
        index :token, :unique => true
        link :account, Account, :to => :tokens

      end

    end
    Token = Riak::Token
  end
end
