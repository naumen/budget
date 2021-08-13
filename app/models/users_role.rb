# Model UsersRole
class UsersRole < ApplicationRecord

  validates :budget_id, :user_id, :role, presence: true

  belongs_to :budget, foreign_key: 'budget_id'
  belongs_to :user, foreign_key: 'user_id' 
end
