class Price < ApplicationRecord

  belongs_to :offer, class_name: "Offer", foreign_key: "offer_id", :primary_key => 'offer_id'


  require 'open-uri'
  require 'nokogiri'
  require 'watir'
  require 'headless'


  def self.saveResults(id)

    @global_msg

    if id.to_i>0
        results = Offer.where(active: 1, offer_id: id)
    else
        results = Offer.where(active: 1, source: 1)
    end

    results.each do |results|

      offer_id=results.offer_id

      self.where(offer_id: offer_id, active: -1).update_all(
        active: -9
      )

      #recent = self.where("offer_id", "created_at < ?", results.offer_id, 30.minutes.ago).count
      #if recent == 0

        msg=""
        ok1=1
        ok2=1

        source = Source.where(active: 1)
        source.each do |source|

          scraper = Scraper.create(
            started_at: Time.now,
            initiated_by: source.short_name
          )
          scraper = scraper.id

          if source.short_name=="TUI"

            source_price="TUI"

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

                msg="#{msg} #{source_price}: new price #{price}; #{seats} |"

                if price > 0
                  self.savePrice(offer_id,price,seats,scraper,source_price)
                end

            rescue OpenURI::HTTPRedirect => redirect

                msg="#{msg} #{source_price}: error with redirecting |"

                self.where(offer_id: results.offer_id, source: source_price).update_all(
                  active: 0
                )
                ok1=0
            end

          elsif source.short_name=="ENT"

            Watir.default_timeout = 90
            Watir.relaxed_locate = false
            url="http://www.enterair.pl/en/buy-ticket#BookingSecondPagePlace:false&#{results.from_airport}&#{results.to_airport}&#{results.departure}&#{results.arrival}&0&PLN&&1=1,2=0,3=0&"
            browser = Watir::Browser.new :chrome, headless: true
            browser.goto url

            source_price="ENT"

            begin
              price=browser.span(:class, ['price', 'total-value']).wait_until_present(6)

                price=browser.span(:class, ['price', 'total-value']).text
                price = price.delete(',').to_i
                seats=10
                browser = browser.close

                msg="#{msg} #{source_price}: new price #{price}; #{seats} |"

                if price > 0
                  self.savePrice(offer_id,price,seats,scraper,source_price)
                end

            rescue
              msg="#{msg} #{source_price}: error with scraping |"

              self.where(offer_id: results.offer_id, source: source_price).update_all(
                active: 0
              )
              ok2=0
            end
          end

          Scraper.where(:id => scraper).update_all(
            finished_at: Time.now,
            output: msg
          )

        end

        # check if the offer should be deactivated
        ok=ok1+ok2
        if ok==0
          Offer.where(offer_id: results.offer_id).update_all(
            active: 0
          )
        else
          self.calculationPrice(offer_id)
        end
        @global_msg="#{@global_msg} #{msg}"
        puts msg

      end
      return @global_msg
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

          Communication.verUpdate(price,old_price,offer_id,seats,source_price)

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
