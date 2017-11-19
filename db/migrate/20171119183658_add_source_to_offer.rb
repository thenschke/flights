class AddSourceToOffer < ActiveRecord::Migration[5.1]
  def change
    add_column :offers, :source, :string
  end
end
