class CreatePrices < ActiveRecord::Migration[5.1]
  def change
    create_table :prices do |t|
      t.integer :scraper_id
      t.integer :offer_id
      t.integer :price
      t.integer :available_seats
      t.integer :active

      t.timestamps
    end
  end
end
