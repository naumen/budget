# Model Division
class Division < ApplicationRecord
  # Division.rebuild!
  # acts_as_nested_set

  # belongs_to :budget, optional: true

#  belongs_to :parent, class_name: 'Division', foreign_key: 'parent_id', optional: true, required: false
#  has_many :children, class_name: 'Division', foreign_key: 'parent_id', dependent: :destroy
  has_many :staff_items

  belongs_to :chief, class_name: 'User'

  def archived
    nil
  end

  def kind
    return 'department' if self.is_department?
    'division'
  end

  def self.reimport
    User.import
    #Division.import
    Position.import
    StaffItem.import
    UserStaff.import
  end

  def self.import
  end

end
