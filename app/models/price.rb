class Price < ApplicationRecord

  def self.saveResults()

    initiated_by = "website"

    results = Offer.where(active: 1)
    results.each do |results|

      scraper = Scraper.create(
        started_at: Time.now,
        initiated_by: initiated_by
      )

      url="https://oferty.tui.pl/new-rezerwacja-oferty?id_o=#{results.offer_id}&trv=ch&ad_count=1&ch_count=0&in_count=0"
      uri=URI.parse(url)
      msg=""

      begin
        uri.open(redirect: false)
        doc = Nokogiri::HTML(open(url))
        price = doc.css('.booking-summary-price-offer').text
        price = price[0...-3].to_i
        seats = doc.css('.cnv-free-seats').text
        seats = seats.delete "\s\n"
        seats = seats[-1]

            exists = self.where(offer_id: results.offer_id).count

            if exists > 0

                old_price = self.where(offer_id: results.offer_id, active:1).last

                # deactive old price
                self.where(offer_id: results.offer_id).update_all(
                  active: 0
                )

                # create a new price
                self.create(
                  offer_id: results.offer_id,
                  price: price,
                  available_seats: seats,
                  scraper_id: scraper.id,
                  active: 1
                )

                msg=msg+"update offer #{results.offer_id}: #{old_price.price} > #{price}; #{old_price.available_seats} > #{seats};"

                if price.to_i!=old_price.price.to_i
                  # SMS
                  if seats.to_i <5
                    wolnych="wolne"
                  else
                    wolnych="wolnych"
                  end

                  account_sid = 'ACb9d1e55b71e1fe1a166fd1bda62e7a86'
                  auth_token = '295a0c999fbdaa8038fd3e3b9056fc29'
                  msg_sms = "Zmiana ceny lotu (#{results.departure} - #{results.arrival}) z #{old_price.price} na #{price}. Zostalo #{seats} #{wolnych} miejsc!"

                  r = Save.where(offer_id: results.offer_id, active: 1)
                  r.each do |u|

                    phone_number = User.where(id: u.user_id).last.phone_number

                    @client = Twilio::REST::Client.new account_sid, auth_token
                    @client.api.account.messages.create({
                        :from => 'DoDubaju',
                        :to => phone_number,
                        :body => msg_sms,
                    })

                    Communication.sentSMS(u.user_id,results.offer_id)
                  end
                end
            else
              # create a new price
              self.create(
                offer_id: results.offer_id,
                price: price,
                available_seats: seats,
                scraper_id: scraper.id,
                active: 1
              )

              msg=msg+"new price #{price}; #{seats};"
            end

        rescue OpenURI::HTTPRedirect => redirect

          msg=msg+"error: with redirecting"

          self.where(offer_id: results.offer_id).update_all(
            active: 0
          )
          Offer.where(offer_id: results.offer_id).update_all(
            active: 0
          )
        end

        Scraper.where(:id => scraper.id).update_all(
          finished_at: Time.now,
          output: msg
        )
    end

    Offer.where("departure < ?", Time.now).update_all(
      active: 0
    )
  end
end
