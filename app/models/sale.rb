# Document comment
class Sale < ApplicationRecord
  validates :budget_id, :sale_channel_id, :user_id, :name, presence: true

  belongs_to :budget
  belongs_to :sale_channel, optional: true
  belongs_to :owner, class_name: 'User', foreign_key: 'user_id'
end
