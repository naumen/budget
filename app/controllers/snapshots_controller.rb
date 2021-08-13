class SnapshotsController < ApplicationController
  def index
    @snapshots = Snapshot.all.order('id DESC')
  end

  def create
    database_name = "#{Time.now.strftime("%Y_%m_%d_%I_%M_%S%p")}.sql"
    current_folder = Rails.root
    current_year = (Time.now + 2.months).year
    root_budget = Budget.find_by(f_year: current_year, budget_id: 0)
    filling_money = Budget.itogi_dohods(root_budget)
    def_prof_money = Budget.def_prof(root_budget)

    @snapshot = Snapshot.new(database_name: database_name, current_folder: current_folder, active: false, filling_money: filling_money, def_prof_money: def_prof_money)
    if @snapshot.save
      if Snapshot.create_dump(database_name)
        redirect_to snapshots_path, success: 'Snapshot добавлен'
      else
        @snapshot.destroy
        redirect_to snapshots_path, danger: 'Snapshot не добавлен. Проблема базы'
      end
    else
      redirect_to snapshots_path, danger: 'Snapshot не добавлен.'
    end
  end

  def backups
    snapshot = Snapshot.find(params[:id])

    if Snapshot.restore_from_dump("#{Rails.root}/db/backups/#{snapshot.database_name}")
      Snapshot.update_all("active = false");
      snapshot.active = true
      if snapshot.save
        redirect_to snapshots_path, success: 'Snapshot восстановлен'
      end
    else
      redirect_to snapshots_path, danger: 'Snapshot не восстановлен'
    end
  end
end