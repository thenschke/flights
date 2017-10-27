class AddOutputToScraper < ActiveRecord::Migration[5.1]
  def change
    add_column :scrapers, :output, :string
  end
end
