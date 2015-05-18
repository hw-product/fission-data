require 'fission-data'

Rails.application.config.before_initialize do

  source = Fission::Data::Models::Source.create(:name => 'internal')
  Fission::Data::Models::User.find_or_create(
    :username => 'fission-admin',
    :source_id => source.id
  )

end
