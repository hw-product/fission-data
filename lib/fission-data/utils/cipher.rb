require 'openssl'
require 'fission-data'
require 'base64'

module Fission
  module Data
    module Utils
      # Simple helper to remove plaintext
      module Cipher

        class << self

          # Encrypt string
          #
          # @param string [String] string to encrypt
          # @param crypt_hash [Hash]
          # @option crypt_hash [String] :key
          # @option crypt_hash [String] :iv
          # @return [String]
          def encrypt(string, crypt_hash)
            cipher = build_cipher(crypt_hash)
            res = cipher.update(string) + cipher.final
            Base64.urlsafe_encode64(res)
          end

          # Decrypt string
          #
          # @param string [String] string to decrypt
          # @param crypt_hash [Hash]
          # @option crypt_hash [String] :key
          # @option crypt_hash [String] :iv
          # @return [String]
          def decrypt(string, crypt_hash)
            string = Base64.urlsafe_decode64(string)
            cipher = build_cipher(crypt_hash.merge(:decrypt => true))
            cipher.update(string) + cipher.final
          end

          # Create a new cipher instance
          #
          # @param args [Hash]
          # @option args [String] :key
          # @option args [String] :iv
          # @option args [Truthy, Falsey] :decrypt
          # @return [OpenSSL::Cipher]
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
end
