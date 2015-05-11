require 'fission-data'

module Fission
  module Data
    module Models

      # Code repository model
      class Repository < Sequel::Model

        self.add_pg_typecast_on_load_columns :metadata

        many_to_one :account
        many_to_many :products
        many_to_many :routes

        def before_destroy
          super
          self.remove_all_products
          self.remove_all_routes
        end

        # Validate instance attributes
        def validate
          super
          validates_presence [:name, :url]
        end

        # @return [Fission::Utils::Smash]
        def metadata
          (self.metadata || {}).to_smash
        end

        # @return [String] short name
        def short_name
          self.name.split('/').last
        end

        # Set value into metadata
        #
        # @param args [String, Symbol, Object]
        # @return [Object]
        # @note argument list is path in hash. Last value is set
        def set_metadata(*args)
          self.metadata.set(*args)
        end

        # Get value from metadata
        #
        # @param args [String, Symbol] path to value
        # @return [Object]
        def get_metadata(*args)
          self.metadata.get(*args)
        end

        class << self

          # Find repository by name filtering on source
          #
          # @param name [String] repository name
          # @param source [String] source name
          # @return [NilClass, Repository]
          def lookup(name, source)
            source = Source.find_by_name(source)
            if(source)
              self.where(
                :account_id => source.accounts_dataset.select(:id)
              )
            end
          end

          # Attempt lookup via available URLs
          #
          # @param url [String]
          # @return [NilClass, Repository]
          def find_by_matching_url(url)
            [url, url.sub('.git', ''), "#{url.sub('.git', '')}.git"].uniq.map do |lookup_url|
              find_by_clone_url(lookup_url) || find_by_url(lookup_url)
            end.compact.first
          end

        end
      end

    end
  end
end
