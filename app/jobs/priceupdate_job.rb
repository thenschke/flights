class PriceupdateJob < ActiveJob::Base
  queue_as "#{Rails.env}_priceupdate"

  def perform()
    results = Offer.order(departure: :asc).where(active: 1, source: 1)
    results.each do |u|
      id=u.offer_id
      #Shoryuken::Client.queues("#{ENV['RAILS_ENV']}_priceupdate").send_message('319092')
      Shoryuken::Client.queues("#{ENV['RAILS_ENV']}_priceupdate").send_message("#{id}")
    end
  end
end
