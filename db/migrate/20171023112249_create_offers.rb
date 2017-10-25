class CreateOffers < ActiveRecord::Migration[5.1]
  def change
    create_table :offers do |t|
      t.integer :scraper_id
      t.integer :offer_id
      t.string :from
      t.string :to
      t.date :departure
      t.date :arrival
      t.integer :active

      t.timestamps
    end
  end
end
