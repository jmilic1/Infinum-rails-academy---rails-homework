class CreateFlights < ActiveRecord::Migration[6.1]
  def change
    create_table :flights do |t|
      t.string :name, null: false
      t.integer :no_of_seats
      t.integer :base_price, null: false
      t.timestamp :departs_at
      t.timestamp :arrives_at

      t.belongs_to :company, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
