Sequel.migration do
  change do
    alter_table(:tokens) do
      add_column :name, String, :null => false
      add_column :description, String
      add_index [:name, :account_id, :user_id], :unique => true
    end
  end
end
