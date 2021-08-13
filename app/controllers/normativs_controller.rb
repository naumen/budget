class NormativsController < ApplicationController
  before_action :set_normativ, only: [:show, :edit, :update, :destroy]
  before_action :initialize_data, only: [:new, :create, :edit, :update, :naklamatr]


  def index
    session[:f_year] = params[:f_year].to_i if [2018, 2019, 2020].include?(params[:f_year].to_i)

    @normativ_types = {}
    @normativ_types['__empty__'] = 'Не указано'
    NormativType.all.each do |n|
      @normativ_types[n.id] = n.name
    end
    @normativ_presenter = NormativPresenter.new(session[:f_year], params[:group_id])

    respond_to do |format|
      format.html do
        # pass
#        render layout: "normativ_layout"
      end
      format.xlsx do
        f_group = ''
        f_group_names = {'__empty__'=>'no_group', '1' => "sale", '2'=>'it', '3'=>'hr', '4' =>'office', '5' =>'razvitie' }
        if params[:group_id] && f_group_names.keys.include?(params[:group_id])
          f_group = "_"+f_group_names[params[:group_id]]
        end
        filename='normativs_'+ session[:f_year].to_s + f_group + '.xls'

        headers['Content-Type'] = "application/vnd.ms-excel"
        headers['Content-Disposition'] = 'attachment; filename="'+filename+'"'
        render :layout=>"excel"
      end
    end
  end

  def __index
    @normativ_types = NormativType.all
    @normativs = Normativ.where(f_year: session[:f_year]).paginate(:page => params[:page], :per_page => 30)

    if params[:budget_id]
      if params[:naklads]
        @normativs = Normativ.includes(:naklads).where( naklads: { budget_id: params[:budget_id] }).order(normativ_type_id: 'desc').paginate(:page => params[:page], :per_page => 30)
      else
        @normativs = Normativ.includes(:budget).where(budgets: { id: params[:budget_id]}).order(normativ_type_id: 'desc').paginate(:page => params[:page], :per_page => 30)
      end
      @budget = Budget.find(params[:budget_id])
    end

    if params[:group]
      session[:group] = params[:group]
    else
      session.delete(:group)
    end
    @normativs = @normativs.where(normativ_type_id: session[:group]) if session[:group]

    order_fields = %w(name metrik budget description normativ normativ_type normativ_in_prev_year diff_in_rub diff_in_proc)
    order_fields.each do |f_name|
      field_name = f_name
      field_name = 'metriks_id' if f_name == 'metrik'
      field_name = 'budget_id' if f_name == 'budget'
      field_name = 'normativ_in_prev_year_id' if f_name == 'normativ_in_prev_year'
      field_name = 'normativ_type_id' if f_name == 'normativ_type'
      if params[f_name] == 'up'
        @normativs.reorder!(f_name)
      else
        @normativs.reorder!(f_name => 'desc')
      end
    end

#     if params[:name]=='up'
#       @normativs.reorder!(:name)
#     elsif params[:name]=='down'
#       @normativs.reorder!(name: 'desc')
#     elsif params[:metrik]=='up'
#       @normativs.reorder!(:metriks_id)
#     elsif params[:metrik]=='down'
#       @normativs.reorder!(metriks_id: 'desc')
#     elsif params[:budget]=='up'
#       @normativs.reorder!(:budget_id)
#     elsif params[:budget]=='down'
#       @normativs.reorder!(budget_id: 'desc')
#     elsif params[:description]=='up'
#       @normativs.reorder!(:description)
#     elsif params[:description]=='down'
#       @normativs.reorder!(description: 'desc')
#     elsif params[:normativ]=='up'
#       @normativs.reorder!(:norm)
#     elsif params[:normativ]=='down'
#       @normativs.reorder!(norm: 'desc')
#     elsif params[:normativ_type]=='up'
#       @normativs.reorder!(:normativ_type_id)
#     elsif params[:normativ_type]=='down'
#       @normativs.reorder!(normativ_type_id: 'desc')
#     elsif params[:normativ_in_prev_year]=='up'
#       @normativs.reorder!(:normativ_in_prev_year_id)
#     elsif params[:normativ_in_prev_year]=='down'
#       @normativs.reorder!(normativ_in_prev_year_id: 'desc')
#     elsif params[:diff_in_rub]=='up'
#       @normativs.reorder!(:diff_in_rub)
#     elsif params[:diff_in_rub]=='down'
#       @normativs.reorder!(diff_in_rub: 'desc')
#     elsif params[:diff_in_proc]=='up'
#       @normativs.reorder!(:diff_in_proc)
#     elsif params[:diff_in_proc]=='down'
#       @normativs.reorder!(diff_in_proc: 'desc')
#     end

    respond_to do |format|
      format.html do
        render layout: "normativ_layout"
      end
      format.xlsx do
        headers['Content-Type'] = "application/vnd.ms-excel"
        f_group = ''
        f_group_names = {'0'=>'no_group', '1' => "sale", '2'=>'it', '3'=>'hr', '4' =>'office', '5' =>'razvitie' }
        if params[:f_group] && f_group_names.keys.include?(params[:f_group])
          f_group = "_"+f_group_names[params[:f_group]]
        end
        headers['Content-Disposition'] = 'attachment; filename=normativs_'+ session[:f_year].to_s + f_group + '.xls"'
        render layout: 'excel'
      end
    end
  end

  def new
    @normativ = Normativ.new
  end

  def create
    if @normativ = Normativ.create(normativ_params)
      redirect_to normativ_path(@normativ.id), success: 'Норматив успешно создан'
    else
      flash.now[:danger] = 'Норматив не создан'
      render :new
    end
  end

  def show

  end

  def edit
  end

  def update
    if @normativ.update(normativ_params)
      redirect_to normativ_path(@normativ.id), success: 'Норматив успешно обновлен'
    else
      flash.now[:danger] = 'Норматив не обновлен'
      render :edit
    end
  end

  def destroy
    @normativ_params.closed_at = DateTime.now + 5.hours
    if @normativ_params.save
      redirect_to normativs_path, success: 'Норматив успешно удален'
    else
      redirect_to normativ_path(@normativ.id), danger: 'Норматив не удален, возникла ошибка'
    end
  end

  def naklamatr
    @normativ_types = {}
    @normativ_types[0] = 'Не указано'
    NormativType.all.each do |n|
      @normativ_types[n.id] = n.name
    end

#     naklad_setting_id = SettingParam.where(name: 'Накладные').pluck(:id)
#     budget_type_ids_from_budget_setting = BudgetSetting.where(settings_params_id: naklad_setting_id).pluck(:budget_setting_type_id)
    @budgets = Budget.includes(:cfo)
                .where(f_year: session[:f_year], budget_type_id: Budget.budget_type_ids_for_nakladn_matrix)
                .all
                .sort_by{|b| b.cfo.name}
                .to_a
                .delete_if{|b| b.archived}


    group_id = params[:group_id].to_i
    group_id = nil if group_id == 0

    @normativs = Normativ.includes(:budget)
                .where(normativ_type_id: group_id, budgets: { f_year: session[:f_year] })
                .order(:name)
  end

  def naklads_create
    f_year = params[:f_year].to_i
    if f_year == 0
      render :plain => "Не указан год"
      return
    end
    archive_at = Time.now
    if Normativ.create_naklads(params, archive_at)
      # сохраняем в кэш метрики
      BudgetMetrik.calculate_and_store_metriks(params[:f_year], archive_at)

      # todo
      if f_year == 2019
        Budget.init_itogo_usage_2019
      elsif f_year == 2020
        Budget.init_itogo_usage_2020
      end

      flash.now[:success] = 'Накладные создались'
      redirect_to naklamatr_path(group_id: params[:group_id].to_i), :flash => { :success => "Матрица накладных сохранена" }
    else
      render :naklamatr, danger: 'Накладные не создались'
    end
  end


  private
    def set_normativ
      @normativ = Normativ.find(params[:id])
    end

    def initialize_data
      @budgets = @current_user.is_admin ? Budget.where(f_year: session[:f_year]).order(:name).to_a.delete_if{|b| b.archived} : @current_user.give_available_budgets(session[:f_year]).to_a.delete_if{|b| b.archived} unless @current_user.nil?
      @metriks = Metrik.all
      @cfos = Cfo.where(archived_date: nil).sorted
      @sales_channels = SaleChannel.all
      @users = User.all
      @normativs_in_last_year = Normativ.where(f_year: session[:f_year])
      @normativ_types = NormativType.all
    end

    def normativ_params
      params[:normativ][:norm].gsub!(",",".")
      params[:normativ][:f_year] = session[:f_year]
      params.require(:normativ).permit(:name, :budget_id, :metrik_id, :norm, 
                                        :description, :sostav_zatrat, :comment,
                                       :normativ_in_prev_year_id, :normativ_type_id, :f_year)
    end

    def allow?(user)
      # todo
      if params[:id]
        normativ = Normativ.find(params[:id])
        if normativ.budget.access_for(user)
#          if @budget.f_year != session[:f_year]
#            session[:f_year] = @budget.f_year
#          end
          return true
        else
          return false
        end
      else
        return user.is_admin? || user.login == 'nlikulina'
      end
    end

end
