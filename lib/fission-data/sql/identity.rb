module Fission
  module Data
    module Sql

      class Identity < Sequel::Model

        include Fission::Data::ModelInterface::Identity

        self.add_pg_typecast_on_load_columns :credentials, :extras, :infos

        many_to_one :source, :class => Sql::Source
        many_to_one :user, :class => Sql::User

        def validate
          super
          validates_presence [:uid, :user_id]
        end

        def before_save
          super
          self.credentials = Sequel.hstore(self.credentials)
          self.extras = Sequel.hstore(self.extras)
          self.infos = Sequel.hstore(self.infos)
        end

        def provider_identity
          [self.source.name, self.uid].compact.join('_')
        end

        class << self

          def lookup(uid, provider=nil)
            source = Source.find_by_name(provider || 'internal')
            if(source)
              source.identities_dataset.where(:uid => uid).first
            end
          end

        end

      end

    end
    Identity = Sql::Identity
  end
end
