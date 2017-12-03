class Offer < ApplicationRecord

  has_many :prices, class_name: "Price", foreign_key: "offer_id", :primary_key => 'offer_id'
  has_many :active_prices, -> { where active: 1 }, class_name: "Price", foreign_key: "offer_id", :primary_key => 'offer_id'

  def self.saveResults(entriesArray)

    initiated_by = "website"

    scraper = Scraper.create(
      started_at: Time.now,
      initiated_by: initiated_by
    )

    updated=0
    added=0

    entriesArray.each do |entry|

      exists = self.where(offer_id: entry.offer_id).count

        if exists < 1
          puts "new offer: "+entry.offer_id
          self.create(
            offer_id: entry.offer_id,
            departure: entry.date_from,
            arrival: entry.date_to,
            from_airport: entry.from_airport,
            to_airport: entry.to_airport,
            scraper_id: scraper.id,
            active: 1,
            source: 1
          )
          added=added+1
        else
          puts "updated offer: "+entry.offer_id
          id = self.where(offer_id: entry.offer_id).last.id
          self.where(id: id).update_all(
            departure: entry.date_from,
            arrival: entry.date_to,
            from_airport: entry.from_airport,
            to_airport: entry.to_airport,
            scraper_id: scraper.id,
            active: 1,
            source: 1
          )
          updated=updated+1
        end
    end

    output = "Added: #{added} Updated: #{updated}"
    puts output

    self.where("departure < ? AND active = ?", Time.now, 1).update_all(
      active: 0
    )


    Scraper.where(:id => scraper.id).update_all(
      finished_at: Time.now,
      output: output
    )

  end


  def self.wizzairOffers

    t = Time.now()
    t = t.strftime("%Y-%m-%d")

    start=t

    source="WIZ"
    start_airport="KTW"

    # get next flight from KTW available
    to=PriceLeg.where("active=? AND source=? AND from_airport=? AND flight_date > ?", 1, source, start_airport, t).order(flight_date: :asc)
    to.each do |to|

    # find all returns flight which is more than 3 days later but less or equal 14 days

      from_airport="DWC"

      t3=to.flight_date.to_date+5.days
      t14=to.flight_date.to_date+14.days

      back=PriceLeg.where("active=? AND source=? AND from_airport=? AND flight_date > ? AND flight_date <= ?", 1, source, from_airport, t3, t14).order(flight_date: :asc)
      back.each do |back|

        offer_id="#{to.from_airport}#{to.flight_date}_#{back.from_airport}#{back.flight_date}"
        seats=10
        price=to.price+back.price
        scraper=0

        puts offer_id

      	offer_exists=Offer.where(active: 1, source: 2, offer_id: offer_id).count

        if offer_exists==0

            #add new offer
            self.create(
              offer_id: offer_id,
              departure: to.flight_date,
              arrival: back.flight_date,
              from_airport: to.from_airport,
              to_airport: back.from_airport,
              scraper_id: 0,
              source: 2,
              active: 1
            )
        else

            #notifications for loved offers
            price_exist=Price.where(offer_id: offer_id, source: "WIZ", active: 1).count
            if price_exist >0
              old=Price.where(offer_id: offer_id, source: "WIZ", active: 1).first
              source_price=source
              old_price=old.price

              diff = (price-old_price).abs
              puts diff
              if diff > 20
                Communication.verUpdate(price,old_price,offer_id,seats,source_price)
              end
            end
        end


        Price.where(offer_id: offer_id, active: 1).update_all(
          active: 0
        )

        Price.create(
          offer_id: offer_id,
          price: price,
          available_seats: seats,
          scraper_id: scraper,
          active: 1,
          source: source
        )

      end
    end
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
