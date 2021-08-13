class NormativParam < ApplicationRecord
  validates :budget_id, :norm, :name, presence: true

  belongs_to :budget
  belongs_to :metrik, foreign_key: 'metriks_id', optional: true
  belongs_to :normativ_in_prev_year, foreign_key: 'normativ_in_prev_year_id', class_name: 'Normativ', optional: true
  belongs_to :normativ_type, foreign_key: 'normativ_type_id', optional: true

  belongs_to :normativ_core
  has_many :naklads, table_name: 'Naklad', foreign_key: 'normativ_id', dependent: :destroy, through: :normativ_core


  def diff_in_rub_calc
    self.normativ_in_prev_year.norm - self.norm if self.normativ_in_prev_year
  end

  def diff_in_proc_calc
    return if !self.normativ_in_prev_year
    a = self.normativ_in_prev_year.norm
    b = self.norm

    (((a-b)/(b))*100).round(2)
    # self.normativ_in_prevv_year.norm / self.norm * 100.0
  end
end