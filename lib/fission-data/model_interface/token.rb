module Fission
  module Data
    module ModelInterface

      module Token

        module ClassMethods
        end

        module InstanceMethods

          def before_save
            super
            self.token = Digest::SHA1.hexdigest([Time.now.to_f, rand].join) unless self.token
          end

        end

        class << self

          def included(klass)
            klass.class_eval do
              include InstanceMethods
              extend ClassMethods
            end
          end

        end

      end

    end
  end
end
