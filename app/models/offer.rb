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
        else
          id = self.where(offer_id: entry.offer_id).last.id
          self.where(id: id).update_all(
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

  def self.getTemp(date)

    t=[0,23,24,27,32,37,38,40,41,38,35,31,26]

    date=date+3.days

    @month=date.strftime("%m").to_i
    @month_next=date.to_datetime.next_month.strftime("%m").to_i
    @month_prev=date.to_datetime.prev_month.strftime("%m").to_i
    @day=date.strftime("%d").to_i
    temp=""
    temp_prev=""
    temp_next=""
    k=0
    t.each do |val|

      if k==@month_prev
        temp_prev=val
      elsif k==@month
        temp=val
      elsif k==@month_next
        temp_next=val
      end

      k=k+1
    end


    if @day==15
        est=temp
    elsif @day>15
        x=@day-15
        y=30-x
        est=((x*temp_next)+(y*temp))/30
    elsif @day<15
        x=15-@day
        y=30-x
        est=((x*temp_prev)+(y*temp))/30
    end

    return est;
  end

end
