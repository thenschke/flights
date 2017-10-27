class User < ApplicationRecord

  def self.signin(phone)

    exists = self.where(phone_number: phone).count

      if exists > 0
        user = self.where(phone_number: phone).last
        if user.active==1
          self.where(id: user.id).update_all(
            last_seen: Time.now
          )
        else
          self.where(id: user.id).update_all(
            last_seen: Time.now,
            active: 1
          )
        end
      else
      self.create(
        phone_number: phone,
        nickname: "guest",
        last_seen: Time.now,
        active: 1
      )
    end
  end
end
