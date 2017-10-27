class CreateSaves < ActiveRecord::Migration[5.1]
  def change
    create_table :saves do |t|
      t.integer :user_id
      t.integer :offer_id
      t.integer :active

      t.timestamps
    end
  end
end
