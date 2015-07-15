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
        one_to_many :plans
        one_to_many :product_styles

        # Validate account attributes
        def validate
          super
          unless(self.internal_name)
            self.internal_name = Bogo::Utility.snake(self.name.dup).tr(' ', '_')
          end
          validates_presence [:name, :internal_name]
          validates_unique :name
          validates_unique :internal_name
          validates_unique :vanity_dns
        end

        # force internal name characters
        def before_save
          super
          self.internal_name = self.internal_name.to_s.
            gsub(/[^a-zA-Z0-9_]/, '_').downcase
        end

        def before_destroy
          super
          self.remove_all_repositories
          self.plans.map(&:destroy)
          self.product_features.map(&:destroy)
          if(self.product_style)
            self.product_style.destroy
          end
        end

        def product_style
          self.product_styles.first
        end

        class << self

          # Discover product vanity dns name via glob
          #
          # @param dns_name [String]
          # @return [Product, NilClass]
          # @note supports glob matching
          def find_by_glob_dns(dns_name)
            all.detect do |item|
              File.fnmatch(item.glob_dns.to_s, dns_name)
            end
          end

        end

      end
    end
  end
end
