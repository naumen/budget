class Motivation < ApplicationRecord

  scope :active, -> { where('archived_at IS NULL')}

  belongs_to :stat_zatr
  belongs_to :user, optional: true
  belongs_to :document, optional: true

  def archive!
    self.archived_at = Time.now
    self.save
    self.document.archive! if self.document
  end
end
