
module Fission
  module Data
    module Riak
      class Session < ModelBase

        include Fission::Data::ModelInterface::Session

        bucket :sessions

        value :data, :class => Hash, :default => Hash.new

        link :user, User, :to => :active_session

        # Ensure data value is set
        def before_save
          super
          self.data = Hash.new unless self.data
        end

      end
    end
    Session = Riak::Session
  end
end
