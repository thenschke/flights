class ChangeOfferIdToBeStringInOffers < ActiveRecord::Migration[5.1]
  def change
    change_column :offers, :offer_id, :string
  end
end
