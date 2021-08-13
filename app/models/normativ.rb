# Model Normativ
class Normativ < ApplicationRecord
  validates :budget_id, :metrik_id, :norm, :name, presence: true

  belongs_to :budget
  belongs_to :metrik
  belongs_to :normativ_in_prev_year, foreign_key: 'normativ_in_prev_year_id', class_name: 'Normativ', optional: true
  belongs_to :normativ_type, foreign_key: 'normativ_type_id', optional: true

  # todo destroy
  has_many :naklads, -> { where(archived_at: nil) }

  def log_me(a,b,c,d)

  end

  #  ret = { summa: , metrik_itogo: }
  def info
    info = {}
    ret = 0.0
    metrik_itogo = 0.0
    self.naklads.each do |naklad|
      metrik_summ = 0.0
      if !['По весу', 'Поровну'].include?(self.metrik.name)
        budget_metrik = BudgetMetrik.where( budget_id: naklad.budget_id, metrik_id: self.metrik_id, archived_at: nil ).first
        if budget_metrik
          metrik_value = budget_metrik.value
          metrik_summ = self.norm * metrik_value
          metrik_itogo += metrik_value
        end
      else
        metrik_summ = naklad.summ.to_f
      end
      ret += metrik_summ
    end
    info[:summa] = ret
    info[:metrik_itogo] = nil
    if !['По весу', 'Поровну'].include?(self.metrik.name)
      info[:metrik_itogo] = metrik_itogo
    end

    info
  end

  def summa
    info[:summa]
  end

  def normativ_in_next_year
    Normativ.find_by(normativ_in_prev_year_id: self.id)
  end

#   def self.create_naklads(params)
#     budgets = Budget.all
#     normativs = NormativCore.all
#
#     transaction do
#       Naklad.delete_all
#
#       unless params["normative"].nil?
#         params["normative"].each do |normativ_id, value|
#           value_summ = 0.0
#           normativ = normativs.find(normativ_id)
#           normativ_params = normativ.normativ_params.find_by(closed_at: nil)
#           if normativ_params.metrik && normativ_params.metrik.name == "По весу"
#             value.each do |budget_id, value|
#               value.gsub!(",",".")
#               value_summ += value.to_f
#             end
#           end
#
#           value.each do |budget_id, v|
#             naklads_budget = budgets.find(budget_id)
#             if normativ_params.metrik && normativ_params.metrik.name == "По весу"
#               next if v.to_f == 0.0
#               summ_for_naklads = (normativ_params.norm / value_summ) * v.to_f if value_summ != 0
#               Naklad.create!(budget_id: naklads_budget.id, normativ_id: normativ.id, summ: summ_for_naklads, weight: v.to_f)
#             else
#               #if naklads_budget.metrik.pluck(:id).include? normativ.metriks_id
#               # binding.pry
#               begin
#                 summ_for_naklads = normativ_params.norm * naklads_budget.budget_metrik.find_by(metrik_id: normativ_params.metriks_id).value.to_f
#               rescue
#                 summ_for_naklads = 0
#                 p
#               end
#               Naklad.create!(budget_id: naklads_budget.id, normativ_id: normativ.id, summ: summ_for_naklads) if (normativ_params.metrik && summ_for_naklads > 0)
#               #else
#               #puts "у бюджета Бюджета #{naklads_budget.name} нет нужной метрики"
#             end
#           end
#         end
#       end
#     end
#   end



  def self.create_naklads(params, archive_at)
    f_year  = params[:f_year] || 2019 # todo
    normativs = Normativ.where(f_year: f_year).all
    Naklad.where(f_year: f_year, normativ_id: params[:normativ_ids], archived_at: nil).update_all(archived_at: archive_at)

    transaction do
      unless params["normative"].nil?
        params["normative"].each do |normativ_id, value|
          normativ = normativs.find(normativ_id)

          if ["По весу", "Поровну"].include?(normativ.metrik.name)
            value_summ = 0.0
            value.each do |budget_id, value|
              if normativ.metrik.name == 'По весу'
                value.gsub!(",",".")
                value_summ +=  value.to_f
              else
                value_summ +=  1.0
              end
            end
          end

          value.each do |budget_id, v|
            if ["По весу", "Поровну"].include?(normativ.metrik.name)
              v = 1.0 if normativ.metrik.name == 'Поровну'
              if v.to_f > 0.0
                summ_for_naklads = 0.0
                summ_for_naklads = (normativ.norm / value_summ) * v.to_f if value_summ != 0

                Naklad.create!(
                  normativ_id: normativ.id,
                  budget_id:   budget_id,
                  weight:      v.to_f,
                  summ:        summ_for_naklads.to_f,
                  f_year:      f_year
                )
              end
            else
              Naklad.create!(
                normativ_id: normativ.id,
                budget_id:   budget_id,
                f_year:      f_year
              )
            end
          end
        end
      end
    end
  end

  def diff_in_rub_calc
    self.normativ_in_prev_year.norm - self.norm if self.normativ_in_prev_year
  end

  def diff_in_proc_calc
    return if !self.normativ_in_prev_year
    a = self.normativ_in_prev_year.norm
    b = self.norm

    (((a-b)/(b))*100).round(2)
    # self.normativ_in_prev_year.norm / self.norm * 100.0
  end
end
