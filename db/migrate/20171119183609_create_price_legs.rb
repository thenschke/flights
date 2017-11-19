class CreatePriceLegs < ActiveRecord::Migration[5.1]
  def change
    create_table :price_legs do |t|
      t.integer :scraper_id
      t.integer :price
      t.string :source
      t.date :flight_date
      t.string :from_airport
      t.string :to_airport
      t.string :string
      t.integer :active

      t.timestamps
    end
  end
end
