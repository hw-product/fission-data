
module Fission
  module Data
    module Riak
      class Session < ModelBase

        bucket :sessions

        value :data, :class => Hash, :default => Hash.new

        link :user, User, :to => :active_session

        # Ensure data value is set
        def before_save
          super
          self.data = Hash.new unless self.data
        end

        # keys_and_value:: keys to walk. Last arg is value
        # Set value into session_data hash
        def set(*keys_and_value)
          result = Hash.walk_set(self.data, *keys_and_value)
          self.save
          result
        end

        # keys:: keys to walk
        # Return value at end of path
        def get(*keys)
          Hash.walk_get(self.data, *keys)
        end

      end
    end
    Session = Riak::Session
  end
end
