module Fission
  module Data
    module ModelInterface

      module Repository

        class << self

          def included(klass)
            klass.class_eval do
              class << self

                # List displayable attributes
                def display_attributes
                  [:name, :url, :private]
                end

                # URL based lookup helper
                def find_by_matching_url(url)
                  [url, url.sub('.git', ''), "#{url.sub('.git', '')}.git"].uniq.map do |lookup_url|
                    find_by_clone_url(lookup_url) || find_by_url(lookup_url)
                  end.compact.first
                end

              end

              # Return short name if long name
              def short_name
                name.split('/').last
              end

              # args:: keys to walk. Last arg is value
              # Set value into metadata hash
              def set_metadata(*args)
                unless(self.metadata)
                  self.metadata = Fission::Data::Hash.new
                end
                Fission::Data::Hash.walk_set(self.metadata, *args)
              end

              # args:: keys to walk
              # Return value at end of path
              def get_metadata(*args)
                if(self.metadata)
                  Fission::Data::Hash.walk_get(self.metadata, *args)
                end
              end

            end
          end
        end

      end

    end
  end
end
