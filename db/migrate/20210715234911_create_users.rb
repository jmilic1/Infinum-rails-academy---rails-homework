class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      # t.string :email, null: false
      t.index [:email], unique: true

      t.timestamps null: false
    end
  end
end
