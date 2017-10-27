class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :phone_number
      t.string :nickname
      t.datetime :last_seen
      t.integer :active

      t.timestamps
    end
  end
end
