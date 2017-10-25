class Offer < ApplicationRecord

  def self.saveResults(entriesArray)

    from_airport = "POZ"
    to_airport = "RKT"
    initiated_by = "website"

    scraper = Scraper.create(
      started_at: Time.now,
      initiated_by: initiated_by
    )

    entriesArray.each do |entry|

      exists = self.where(offer_id: entry.offer_id).count

        if exists < 1
          self.create(
            offer_id: entry.offer_id,
            departure: entry.date_from,
            arrival: entry.date_to,
            from: from_airport,
            to: to_airport,
            scraper_id: scraper.id,
            active: 1
          )
        end
    end

    self.where("departure < ?", Time.now).update_all(
      active: 0
    )

    Scraper.where(:id => scraper.id).update_all(
      finished_at: Time.now
    )

  end
end
