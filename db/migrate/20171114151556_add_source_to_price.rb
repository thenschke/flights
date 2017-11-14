class AddSourceToPrice < ActiveRecord::Migration[5.1]
  def change
    add_column :prices, :source, :string
  end
end
