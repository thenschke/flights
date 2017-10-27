Rails.application.routes.draw do

  root 'application#results'
  get 'price/:id' => 'application#scrape_tui_price'
  get 'price' => 'application#scrape_tui_price'
  get 'scrape_tui' => 'application#scrape_tui'
  get 'json' => 'application#results_json'
  get 'changechecker' => 'application#changechecker'
  get 'signin' => 'application#signin'
  get 'price_update' => 'application#price_update'

end
