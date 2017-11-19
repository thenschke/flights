class PriceLeg < ApplicationRecord

  def self.wizzairPriceLeg

    scraper = Scraper.create(
      started_at: Time.now,
      initiated_by: "WIZ"
    )
    scraper = scraper.id

    t = Time.now()
    t = t.strftime("%Y-%m-%d")
    from="KTW"
    to="DWC"
    source="WIZ"

    url="https://wizzair.com/en-gb/main-page/#/booking/select-flight/#{from}/#{to}/#{t}/null/1/0/0"

    browser = Watir::Browser.new :chrome
    browser.goto url

      20.times do
          browser.button(:class => ['booking-flow__flight-select__chart__button', 'booking-flow__flight-select__chart__button--next']).wait_until_present.click
          sleep 1
      end

      browser.divs(:class => "booking-flow__flight-select__chart__day__info").each do |cal|

        time=cal.element(:tag_name => "time", :class => ['booking-flow__flight-select__chart__day__number', 'title', 'title--2']).attribute_value("datetime")[0..9]
        if cal.span(:class => "booking-flow__flight-select__chart__day__price").exists?
          price=cal.span(:class => "booking-flow__flight-select__chart__day__price").text[2..9].to_i

          puts "#{from}-#{to} #{time}: #{price}"

          self.where(source: source, flight_date: time, from_airport: from, to_airport: to, active: 1).update_all(
            active: 0
          )

          self.create(
            price: price,
            scraper_id: scraper,
            active: 1,
            source: source,
            flight_date: time,
            from_airport: from,
            to_airport: to
          )

        end
      end


      from_back="DWC"
      to_back="KTW"

      url_back="https://wizzair.com/en-gb/main-page/#/booking/select-flight/#{from_back}/#{to_back}/#{t}/null/1/0/0"

      browser = Watir::Browser.new :chrome
      browser.goto url_back

        20.times do
            browser.button(:class => ['booking-flow__flight-select__chart__button', 'booking-flow__flight-select__chart__button--next']).wait_until_present.click
            sleep 1
        end

        browser.divs(:class => "booking-flow__flight-select__chart__day__info").each do |cal|

          time=cal.element(:tag_name => "time", :class => ['booking-flow__flight-select__chart__day__number', 'title', 'title--2']).attribute_value("datetime")[0..9]
          if cal.span(:class => "booking-flow__flight-select__chart__day__price").exists?
            price=cal.span(:class => "booking-flow__flight-select__chart__day__price").text[3..10].to_i

            puts "#{from_back}-#{to_back} #{time}: #{price}"

            self.where(source: source, flight_date: time, from_airport: from_back, to_airport: to_back, active: 1).update_all(
              active: 0
            )

            self.create(
              price: price,
              scraper_id: scraper,
              active: 1,
              source: source,
              flight_date: time,
              from_airport: from_back,
              to_airport: to_back
            )

          end
        end

      Scraper.where(:id => scraper).update_all(
          finished_at: Time.now,
      )
  end
end
