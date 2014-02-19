require 'digest/sha2'
require 'fission-data'

module Fission
  module Data

    class Token < ModelBase

      bucket :tokens

      value :token, :class => String, :default => Digest::SHA2.hexdigest([Time.now.to_f, rand].join)
      index :token, :unique => true
      link :account, Account, :to => :tokens

      def before_save
        super
        self.token = Digest::SHA2.hexdigest([Time.now.to_f, rand].join) unless self.token
      end

    end

  end
end
