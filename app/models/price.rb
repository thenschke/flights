class Price < ApplicationRecord

  belongs_to :offer, class_name: "Offer", foreign_key: "offer_id", :primary_key => 'offer_id'

  def self.saveResults(id)

    if id.to_i>0
        results = Offer.where(active: 1, offer_id: id)
    else
        results = Offer.where(active: 1)
    end

    results.each do |results|

      offer_id=results.offer_id

      self.where(offer_id: offer_id, active: -1).update_all(
        active: -9
      )

      #recent = self.where("offer_id", "created_at < ?", results.offer_id, 30.minutes.ago).count
      #if recent == 0

        msg=""

        source = Source.where(active: 1)
        source.each do |source|

          scraper = Scraper.create(
            started_at: Time.now,
            initiated_by: source.short_name
          )
          scraper = scraper.id

          if source.short_name=="TUI"

            begin
              url="https://oferty.tui.pl/new-rezerwacja-oferty?id_o=#{results.offer_id}&trv=ch&ad_count=1&ch_count=0&in_count=0"
              uri=URI.parse(url)
              uri.open(redirect: false)
              doc = Nokogiri::HTML(open(url))
                price = doc.css('.booking-summary-price-offer').text
                price = price[0...-3].to_i
                seats = doc.css('.cnv-free-seats').text
                seats = seats.delete "\s\n"
                seats = seats[-1]
                source_price="TUI"

                msg=msg+"new price #{price}; #{seats}; #{source_price};"

                self.savePrice(offer_id,price,seats,scraper,source_price)

            rescue OpenURI::HTTPRedirect => redirect

                msg=msg+"error: with redirecting"

                self.where(offer_id: results.offer_id).update_all(
                  active: 0
                )
                Offer.where(offer_id: results.offer_id).update_all(
                  active: 0
                )
            end

          elsif source.short_name=="ENT"

            begin
              url="http://www.enterair.pl/en/buy-ticket#BookingSecondPagePlace:false&#{results.from_airport}&#{results.to_airport}&#{results.departure}&#{results.arrival}&0&PLN&&1=1,2=0,3=0&"
              browser = Watir::Browser.new :chrome, headless: true
              browser.goto url
                price=browser.span(:class, ['price', 'total-value']).wait_until_present.text
                price = price.delete(',').to_i
                seats=10
                source_price="ENT"

              msg=msg+"new price #{price}; #{seats}; #{source_price};"

              self.savePrice(offer_id,price,seats,scraper,source_price)

            rescue OpenURI::HTTPRedirect => redirect

              msg=msg+"error: with redirecting"

              self.where(offer_id: results.offer_id).update_all(
                active: 0
              )
              Offer.where(offer_id: results.offer_id).update_all(
                active: 0
              )
            end
          end

          Scraper.where(:id => scraper).update_all(
            finished_at: Time.now,
            output: msg
          )
        end
        self.calculationPrice(offer_id)
      end
    end


  def self.savePrice(offer_id,price,seats,scraper,source_price)

    self.create(
      offer_id: offer_id,
      price: price,
      available_seats: seats,
      scraper_id: scraper,
      active: -1,
      source: source_price
    )

  end

  def self.calculationPrice(offer_id)
        exists_new = self.where(offer_id: offer_id, active: -1).count
        exists_old = self.where(offer_id: offer_id, active: 1).count

        if exists_new && exists_old

          old_price=self.where(offer_id: offer_id, active: 1).order(created_at: :desc).first
          new_price=self.where(offer_id: offer_id, active: -1).order(price: :asc).first

          price = new_price.price
          seats = new_price.available_seats
          source_price = new_price.source

          offer = Offer.where(offer_id: offer_id, active: 1).last

            if price.to_i!=old_price.price.to_i
                      # SMS
                      if seats.to_i <2
                        wolnych="wolne miejsce"
                      elsif seats.to_i <5
                        wolnych="wolne miejsca"
                      else
                        wolnych="wolnych miejsc"
                      end

                      msg_sms = "Zmiana ceny lotu (#{offer.departure} - #{offer.arrival} z #{offer.from_airport}) z #{old_price.price} na #{price} liniami #{source_price}. Zostalo #{seats} #{wolnych}!"

                      r = Save.where(offer_id: offer_id, active: 1)
                      r.each do |u|
                          user_id=u.user_id
                          Communication.sentSMS(user_id,offer_id,msg_sms)
                      end

            end
          end

          self.where(offer_id: offer_id, active: 1).update_all(
              active: 0
          )

          if exists_new
            new_price=self.where(offer_id: offer_id, active: -1).order(price: :asc).first
            self.where(id: new_price.id).update_all(
                active: 1
            )
          end

      Offer.where("departure < ?", Time.now).update_all(
        active: 0
      )
  end
end
