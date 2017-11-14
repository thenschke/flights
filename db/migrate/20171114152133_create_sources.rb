class CreateSources < ActiveRecord::Migration[5.1]
  def change
    create_table :sources do |t|
      t.string :short_name
      t.string :long_name
      t.string :url
      t.string :logo
      t.integer :active

      t.timestamps
    end
  end
end
