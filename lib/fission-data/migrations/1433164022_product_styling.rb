Sequel.migration do

  change do

    create_table(:product_styles) do
      column :style, :json, :null => false
      foreign_key :product_id, :null => false, :unique => true
      primary_key :id
    end

  end

end
