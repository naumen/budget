# Model UserStaff
class UserStaff < ApplicationRecord
  belongs_to :staff_item
  belongs_to :user, optional: true

  def self.import
  end

end
