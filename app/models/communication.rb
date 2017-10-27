class Communication < ApplicationRecord

  self.inheritance_column = "inheritance_type"

  def self.sentSMS(user_id, offer_id)

    phone_number = User.where(id: user_id).last.phone_number
    medium="SMS"
    type="Price alert"

    self.create(
      offer_id: offer_id,
      user_id: user_id,
      phone_number: phone_number,
      medium: medium,
      type: type
    )
  end
end
