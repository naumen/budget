class RequestChangeHistory < ApplicationRecord
  belongs_to :request_change
  belongs_to :user

  def self.log(request_change_id, user_id, state)
    rch = RequestChangeHistory.new
    rch.request_change_id = request_change_id
    rch.user_id = user_id
    rch.state   = state
    rch.save
  end
end
