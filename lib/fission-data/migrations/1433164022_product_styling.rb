Sequel.migration do

  change do

    create_table(:product_styles) do
      String :style, :null => false
      foreign_key :product_id, :null => false, :unique => true
    end

  end

end
