Sequel.migration do
  change do

    add_column :service_config_items, :enabled, TrueClass, :null => false, :default => true
    add_column :service_config_items, :type, String, :null => false, :default => 'string'

  end
end
