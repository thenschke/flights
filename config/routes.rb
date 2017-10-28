Rails.application.routes.draw do

  root 'application#results'
  get 'offer_update' => 'application#offer_update'
  get 'changechecker' => 'application#changechecker'
  get 'signin' => 'application#signin'
  get 'price_update' => 'application#price_update'

  get 'worker_result' => 'application#worker_result'

end
