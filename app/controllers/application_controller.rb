class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  require 'open-uri'
  require 'nokogiri'
  require 'watir'


  class Entry
    def initialize(date_from, date_to, offer_id)
      @date_from = date_from[0...10]
      @date_to = date_to[0...10]
      @offer_id = offer_id
    end
    attr_reader :date_from
    attr_reader :date_to
    attr_reader :offer_id
  end

  def changechecker
    if params[:status]=="true"
      state=1
    else
      state=0
    end

    offer_id=params[:offer_id]
    user_id=session[:user_id]
    Save.loveit(user_id,offer_id,state)

  end

  def signin
    phone = params[:phone].delete('^0-9')
    User.signin(phone)
    session[:user_id]=User.where(phone_number: phone, active: 1).order(last_seen: :asc).last.id

    redirect_to "/?list=on"
  end

  def offer_update

      @entriesArray = []

      [0,4,9].each do |i|
        # Scrapping the content
        ["ln7","ln9-13"].each do |k|
          browser = Watir::Browser.new
          browser.goto "http://oferty.tui.pl/bilety-lotnicze/wyniki-wyszukiwania#/flight_from_label=Pozna%C5%84&airport_from%5B%5D=POZ&flight_to_label=Ras+al+Khaimah&airport_to%5B%5D=334&dt_from=&dt_to=&dt_length=#{k}&adults=1&children=0&page=#{i}"
          doc = Nokogiri::HTML.parse(browser.html)

          # Narrow down on flights results only
          entries = doc.css('.result')
          entries.each do |entry|
            date_from = entry.css('.result-date-from').text
            date_to = entry.css('.result-date-to').text
            link = entry.css('.result-price-per-person>a')[0]['href']
            offer_id = link[49,6]
            @entriesArray << Entry.new(date_from, date_to, offer_id)

            Offer.saveResults(@entriesArray)
          end
        end
      end
    redirect_to '/worker_result'
  end

  def results
    render template: 'results'
  end

  def worker_result
    render plain: "OK updated: #{params[:id]}"
  end

  def price_update
      if params[:id]
        @id=params[:id]
      else
        @id=0
      end
      Price.saveResults(@id)
      redirect_to "/worker_result?id=#{@id}"
  end


end
