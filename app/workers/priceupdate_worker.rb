class Priceupdate
  include Shoryuken::Worker
  #shoryuken_options queue: ->{ "#{ENV['RAILS_ENV']}_priceupdate" }
  shoryuken_options queue: "#{Rails.env}_priceupdate", auto_delete: true

  def perform(sqs_msg, body)
    id=body
    #puts id
    Price.saveResults(id)
  end

 end
