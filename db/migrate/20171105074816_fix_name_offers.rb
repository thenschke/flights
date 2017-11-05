class FixNameOffers < ActiveRecord::Migration[5.1]
  def change
    rename_column :offers, :from, :from_airport
    rename_column :offers, :to, :to_airport
  end
end
