require 'fission-data'

if(defined?(Rails) && Rails.application)
  Rails.application.config.before_initialize do

    source = Fission::Data::Models::Source.find_or_create(:name => 'internal')
    Fission::Data::Models::User.find_or_create(
      :username => 'fission-admin',
      :source_id => source.id
    )

  end
end
