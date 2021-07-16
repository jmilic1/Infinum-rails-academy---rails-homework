class CreateFlights < ActiveRecord::Migration[6.1]
  def change
    create_table :flights do |t|
      t.string :name
      t.integer :no_of_seats
      t.integer :base_price, null: false, unique: true
      t.timestamp :departs_at
      t.timestamp :arrives_at

      t.belongs_to :company, index:true, foreign_key: true

      t.timestamps
    end
  end
end
