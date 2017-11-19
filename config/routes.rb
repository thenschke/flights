Rails.application.routes.draw do

  root 'application#results'
  get 'offer_update' => 'application#offer_update'
  get 'changechecker' => 'application#changechecker'
  get 'signin' => 'application#signin'
  get 'price_update' => 'application#price_update'

  get 'worker_result' => 'application#worker_result'
  get 'result_json' => 'application#result_json'

  get 'leg_wizzair' => 'application#leg_wizzair'
  get 'offer_wizzair' => 'application#offer_wizzair'
  

end
