require 'fission-data'

Rails.application.config.before_initialize do

  unless(Fission::Data::Models::Product.find_by_name('Fission'))
    product = Fission::Data::Models::Product.create(:name => 'Fission')
    feature = product.add_product_feature(:name => 'fission_full_access')
    source = Fission::Data::Models::Source.create(:name => 'internal')
    permission = feature.add_permission(:name => 'fission-admin', :pattern => '.*')
    user = source.add_user(:username => 'fission-default-admin')
    user.add_whitelist(:username => 'fission-default-admin')
    user.accounts.first.add_permission(permission)
  end

end
