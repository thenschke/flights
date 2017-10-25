class CreateScrapers < ActiveRecord::Migration[5.1]
  def change
    create_table :scrapers do |t|
      t.datetime :started_at
      t.datetime :finished_at
      t.string :initiated_by

      t.timestamps
    end
  end
end
