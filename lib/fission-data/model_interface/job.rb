module Fission
  module Data
    module ModelInterface

      module Job

        module ClassMethods

          def display_attributes
            [:key, :task, :status, :percent_complete, :last_update]
          end

        end

        module InstanceMethods

          def task
            Fission::Data::Hash.walk_get(self.payload, :data, :router, :action) || self.payload['job']
          end

          def status
            if(self.payload['error'])
              :error
            else
              self.payload['complete'].include?(self.payload['job']) ? :complete : :in_progress
            end
          end

          def percent_complete
            total = [
              done = Hash.walk_get(self.payload, :complete).find_all{|x|!x.include?(':')},
              Hash.walk_get(self.payload, :data, :router, :route)
            ].flatten.compact
            ((done.count / total.count.to_f) * 100).to_i
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
