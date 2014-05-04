require 'openssl'
require 'fission-data'

module Fission
  module Data
    module Utils
      module Cipher

        class << self

          def encrypt(string, crypt_hash)
            cipher = build_cipher(crypt_hash)
            cipher.update(string) + cipher.final
          end

          def decrypt(string, crypt_hash)
            cipher = build_cipher(crypt_hash.merge(:decrypt => true))
            cipher.update(string) + cipher.final
          end

          def build_cipher(args={})
            cipher = OpenSSL::Cipher.new('AES-256-CBC')
            args[:decrypt] ? cipher.decrypt : cipher.encrypt
            [:key, :iv].each do |k|
              if(args[k])
                cipher.send("#{k}=", args[k])
              end
            end
            cipher
          end

      end
    end
  end
end
