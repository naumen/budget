class MotivationsController < ApplicationController
  before_action :set_motivation, only: [:edit, :update, :destroy]
  before_action :init_data, only: [:edit, :update, :new]

  def index
    #@motivations = Motivation.active
    @rows = []
    StatZatr.where(
      f_year: session[:f_year],
      spr_stat_zatrs_id: SprStatZatr.get_premii_item.id).sort_by{|s| s.budget.name}.each do |s|
      @rows << { stat_zatr: s}
    end

    @cfos = Cfo.all.sort_by{|c| c.name}

    @summary_cfos = {} # cfo_id budget_id { stat_zatrs, motivations }
    @rows.each do |r|
      s = r[:stat_zatr]
      cfo_id = s.budget.cfo.id
      budget_id = s.budget.id
      @summary_cfos[cfo_id] ||= {}
      @summary_cfos[cfo_id][budget_id] ||= { stat_zatrs: 0, motivations: 0 }
      @summary_cfos[cfo_id][budget_id][:stat_zatrs] += 1
      if s.motivations.size > 0
        @summary_cfos[cfo_id][budget_id][:motivations] += 1
      end
    end
  end

  def new
    @motivation = Motivation.new
    @motivation.stat_zatr_id = params[:stat_zatr_id]
  end

  def create
    document_id = nil

    if !params['motivation']['file'].nil?
      document_id = Document.store_file(:file => params['motivation']['file'])
    end

    _create_params = document_id.nil? ? motivation_params : motivation_params.merge({ document_id: document_id })

    @motivation = Motivation.new(_create_params)
    @motivation.f_year = @motivation.stat_zatr.f_year
    @motivation.author = @current_user.id

    if @motivation.save
      if @motivation.document
        @motivation.document.owner = @motivation
        @motivation.document.save
      end
      redirect_to motivations_path(anchor: "stat_zatr_#{@motivation.stat_zatr.id}"), success: 'Мотивация создана'
    else
      flash.now[:danger] = 'Мотивация не создана'
      render :new
    end
  end

  def edit; end

  def update

    if !params['motivation']['file'].nil?
      document_id = Document.store_file(:file => params['motivation']['file'], :owner => @motivation)
    end

    if document_id.nil?
      _update_params = motivation_params
    else
      # archive old
      @motivation.document.archive! if @motivation.document
      _update_params = motivation_params.merge({ document_id: document_id })
    end

    if @motivation.update(_update_params)
      redirect_to motivations_path(anchor: "stat_zatr_#{@motivation.stat_zatr.id}"), success: 'Мотивация обновлена'
    else
      flash.now[:danger] = 'Мотивация не обновлена'
      render :edit
    end
  end

  def destroy
    if @motivation.archive!
      redirect_to motivations_path, success: 'Мотивация удалена'
    else
      redirect_to motivations_path, danger: 'Мотивация не удалена'
    end
  end

  private

  def set_motivation
    @motivation = Motivation.find(params[:id])
  end

  def init_data
    @cfos = Cfo.where(archive_date: nil).sorted.to_a.delete_if{|cfo| cfo.name.downcase.index("закрыт")}
    @users = User.all.sorted
  end

  def motivation_params
    params.require(:motivation).permit(:name, :user_id, :stat_zatr_id)
  end

  def allow?(user)
    user.is_admin?
  end

end