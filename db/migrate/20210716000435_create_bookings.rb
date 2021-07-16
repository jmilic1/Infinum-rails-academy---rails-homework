class CreateBookings < ActiveRecord::Migration[6.1]
  def change
    create_table :bookings do |t|
      t.integer :no_of_seats
      t.integer :seat_price, null: false, unique: true

      t.belongs_to :flight, index:true, foreign_key: true
      t.belongs_to :user, index:true, foreign_key: true

      t.timestamps
    end
  end
end
