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
end
