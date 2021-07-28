class AddPasswordDigestToUsers < ActiveRecord::Migration[6.1]
  def up
    add_column :users, :password_digest, :string , null: true
    User.update_all(password_digest: '')
    change_column :users, :password_digest, :string, null: false
  end
  def down
    remove_column :users, :password_digest
  end
end
