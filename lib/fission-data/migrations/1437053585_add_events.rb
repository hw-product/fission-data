Sequel.migration do
  change do

    create_table(:events) do
      String :type, :null => false
      String :message_id
      Float :stamp, :null => false
      DateTime :created_at
      column :data, :json
      primary_key :id
    end

  end
end
