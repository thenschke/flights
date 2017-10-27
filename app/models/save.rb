class Save < ApplicationRecord

def self.loveit(user_id,offer_id,state)

  exists = self.where(offer_id: offer_id, user_id: user_id).count

    if exists > 0
      self.where(offer_id: offer_id, user_id: user_id).update_all(
        active: state
      )
    else
      self.create(
        offer_id: offer_id,
        user_id: user_id,
        active: 1
      )
    end
  end
end
