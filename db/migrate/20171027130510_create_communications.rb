class CreateCommunications < ActiveRecord::Migration[5.1]
  def change
    create_table :communications do |t|
      t.string :phone_number
      t.integer :user_id
      t.integer :offer_id
      t.string :medium
      t.string :type

      t.timestamps
    end
  end
end
