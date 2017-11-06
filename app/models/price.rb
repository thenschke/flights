class Price < ApplicationRecord

  belongs_to :offer, class_name: "Offer", foreign_key: "offer_id", :primary_key => 'offer_id'

  def self.saveResults(id)


    initiated_by = "website"

    if id.to_i>0
        results = Offer.where(active: 1, offer_id: id)
    else
        results = Offer.where(active: 1)
    end

    results.each do |results|

      recent = self.where("offer_id", "created_at < ?", results.offer_id, 30.minutes.ago).count
      #if recent == 0

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
                    if seats.to_i <2
                      wolnych="wolne miejsce"
                    elsif seats.to_i <5
                      wolnych="wolne miejsca"
                    else
                      wolnych="wolnych miejsc"
                    end

                    msg_sms = "Zmiana ceny lotu (#{results.departure} - #{results.arrival}) z #{old_price.price} na #{price}. Zostalo #{seats} #{wolnych}!"

                    r = Save.where(offer_id: results.offer_id, active: 1)
                    r.each do |u|

                      phone_number = User.where(id: u.user_id).last.phone_number

                      account_sid = "#{ENV['TWILIO_SID']}"
                      auth_token = "#{ENV['TWILIO_TOKEN']}"

                      @client = Twilio::REST::Client.new account_sid, auth_token
                      @client.api.account.messages.create({
                          :from => 'DoDubaju',
                          :to => phone_number,
                          :body => msg_sms,
                      })

                      Communication.sentSMS(u.user_id,results.offer_id,msg_sms)
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
      #end

      Offer.where("departure < ?", Time.now).update_all(
        active: 0
      )
    end
  end
end
