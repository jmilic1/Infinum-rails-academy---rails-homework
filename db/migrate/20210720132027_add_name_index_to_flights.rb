class AddNameIndexToFlights < ActiveRecord::Migration[6.1]
  def change
    add_index :flights, [:name, :company_id], unique: true
  end
end
