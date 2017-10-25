class Price < ApplicationRecord

  def self.saveResults()

    initiated_by = "website"

    results = Offer.where(active: 1)
    results.each do |results|

      doc = Nokogiri::HTML(open("https://oferty.tui.pl/new-rezerwacja-oferty?id_o=#{results.offer_id}&trv=ch&ad_count=1&ch_count=0&in_count=0"))
      price = doc.css('.booking-summary-price-offer').text
      price = price[0...-3]
      seats = doc.css('.cnv-free-seats').text
      seats = seats.delete "\s\n"
      seats = seats[-1]

          scraper = Scraper.create(
            started_at: Time.now,
            initiated_by: initiated_by
          )

          exists = self.where(offer_id: results.offer_id).count

          if exists > 0
            self.where(offer_id: results.offer_id).update_all(
              active: 0
            )
          end

            self.create(
              offer_id: results.offer_id,
              price: price,
              available_seats: seats,
              scraper_id: scraper.id,
              active: 1
            )

          Scraper.where(:id => scraper.id).update_all(
            finished_at: Time.now
          )

        end
    end
end
