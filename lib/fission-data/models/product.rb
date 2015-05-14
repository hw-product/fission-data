require 'fission-data'

module Fission
  module Data
    module Models

      # Product
      class Product < Sequel::Model

        one_to_many :product_features
        one_to_many :static_pages
        many_to_one :service_group
        many_to_many :repositories
        many_to_many :plans

        # Validate account attributes
        def validate
          super
          unless(self.internal_name)
            self.internal_name = self.name.dup
          end
          validates_presence [:name, :internal_name]
          validates_unique :name
          validates_unique :internal_name
        end

        # force internal name characters
        def before_save
          super
          self.internal_name = self.internal_name.to_s.
            gsub(/[^a-zA-Z0-9_]/, '_').downcase
        end

        def before_destroy
          super
          self.remove_all_plans
          self.remove_all_repositories
          self.product_features(&:destroy)
        end

      end
    end
  end
end
