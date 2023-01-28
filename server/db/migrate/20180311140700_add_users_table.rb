class AddUsersTable < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :login
      t.string :salt
      t.string :pwhash
    end
  end
end
