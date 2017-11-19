class ChangeOfferIdToBeStringInPrices < ActiveRecord::Migration[5.1]
  def change
    change_column :prices, :offer_id, :string
  end
end
