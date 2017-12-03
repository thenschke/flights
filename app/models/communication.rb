class Communication < ApplicationRecord

  self.inheritance_column = "inheritance_type"

  def self.sentSMS(user_id, offer_id, msg_sms)

    phone_number = User.where(id: user_id).last.phone_number

    account_sid = "#{ENV['TWILIO_SID']}"
    auth_token = "#{ENV['TWILIO_TOKEN']}"

    @client = Twilio::REST::Client.new account_sid, auth_token
    @client.api.account.messages.create({
        :from => 'DoDubaju',
        :to => phone_number,
        :body => msg_sms,
    })

    medium="SMS"
    type="Price alert"

    self.create(
      offer_id: offer_id,
      user_id: user_id,
      phone_number: phone_number,
      medium: medium,
      type: type,
      msg_content: msg_sms
    )
  end

  def self.verUpdate(price,old_price,offer_id,seats,source_price)

    if price!=old_price
      # SMS
      if seats.to_i <2
          wolnych="wolne miejsce"
      elsif seats.to_i <5
          wolnych="wolne miejsca"
      else
          wolnych="wolnych miejsc"
      end

      exists = Offer.where(offer_id: offer_id, active: 1).count

      if exists > 0
        offer = Offer.where(offer_id: offer_id, active: 1).last

        msg_sms = "Zmiana ceny lotu (#{offer.departure} - #{offer.arrival} z #{offer.from_airport}) z #{old_price} na #{price} liniami #{source_price}. Zostalo #{seats} #{wolnych}!"

        r = Save.where(offer_id: offer_id, active: 1)
        r.each do |u|
            user_id=u.user_id
            self.sentSMS(user_id,offer_id,msg_sms)
        end
      end
    end
  end
end
