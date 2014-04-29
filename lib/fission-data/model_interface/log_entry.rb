module Fission
  module Data
    module ModelInterface

      module LogEntry

        class << self

          def included(klass)
            klass.class_eval do
              class << self
                def display_attributes
                  [:source, :path]
                end

                def restrict(user)
                  # only against accts accessible
                end

                def add(args={})
                  log = Fission::Data::Log.find_or_create(
                    :path => args[:log],
                    :source => args[:source]
                  )
                  tags = args.fetch(:tags, []).map do |tag_name|
                    Fission::Data::Tag.find_or_create(:name => tag_name)
                  end
                  entry = create(
                    :log => log,
                    :entry_time => args[:timestamp],
                    :entry => args[:entry]
                  )
                  tags.each do |tag|
                    entry.add_tag(tag)
                  end
                  entry
                end

              end
            end
          end
        end

      end

    end
  end
end
