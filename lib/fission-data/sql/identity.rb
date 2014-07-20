module Fission
  module Data
    module Sql

      class Identity < Sequel::Model

        SALTER = 'fission-data-salter-00220'
        SALTER_JOINER = '~~*~~'

        include Fission::Data::ModelInterface::Identity

        self.add_pg_typecast_on_load_columns :extras, :infos

        many_to_one :source, :class => Sql::Source
        many_to_one :user, :class => Sql::User

        def validate
          super
          validates_presence [:uid, :user_id]
        end

        def before_save
          super
          unless(self.values[:credentials])
            self.values[:credentials] = {}
          end
          self.credentials = Utils::Cipher.encrypt(
            JSON.dump(self[:credentials]),
            :key => [SALTER, self.user.username, self.user.session.get(:login_time).to_s].join(SALTER_JOINER),
            :iv => self.user.session.get(:login_time).to_s
          )
          self.extras = Sequel.pg_json(self.extras)
          self.infos = Sequel.pg_json(self.infos)
        end

        def credentials
          begin
            res = Smash.new(
              JSON.load(
                Utils::Cipher.decrypt(
                  super,
                  :key => [
                    SALTER, self.user.username, self.user.session.get(:login_time)
                  ].join(SALTER_JOINER),
                  :iv => self.user.session.get(:login_time)
                )
              )
            )
            res
          rescue
            nil
          end
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
