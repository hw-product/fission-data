module Fission
  module Data
    module ModelInterface

      module Token

        class << self
          def included(klass)
            klass.class_eval do
              def before_save
                super
                self.token = Digest::SHA1.hexdigest([Time.now.to_f, rand].join) unless self.token
              end
            end
          end
        end

      end

    end
  end
end
