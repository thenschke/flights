Rails.application.routes.draw do

  root 'application#results'
  get 'price/:id' => 'application#scrape_tui_price'
  get 'price' => 'application#scrape_tui_price'
  get 'scrape_tui' => 'application#scrape_tui'
  get 'json' => 'application#results_json'

end
