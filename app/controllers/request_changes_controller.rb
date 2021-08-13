class RequestChangesController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:create_save_action]

  before_action :set_request_change, only: [:show, :edit, :update, :destroy, :set_action, :proceed, :set_state, :sign]

  def set_state
    new_state = params[:state]
    if new_state == 'to_confirm'
       @request_change.set_state("На согласовании", @current_user)
    elsif new_state == 'to_edit'
       @request_change.set_state("Редактируется", @current_user)
    end

    # прямая обработка
    if params[:state] == 'direct_proceed' && @request_change.direct_proceed?
      @request_change.proceed(current_user)
    end

    redirect_to @request_change
  end

  # create, update:
  #   POST /request_change/:id/create_save_action
  #   - [action_id] {update}
  #   - [action_type] {create}
  #   - json_content
  def create_save_action
    request_change = RequestChange.find(params[:id])
    options = {
      action_id:    params[:action_id],
      action_type:  params[:action_type],
      json_content: params[:json_content]
    }
    result = request_change.create_save_action(options)
    render json: { result: result}
  end

  def sign
    result = params[:result].to_i
    @request_change.sign(result, @current_user)
    redirect_to @request_change
  end

  def show
    @budget = @request_change.budget
    @presenter = BudgetPresenter.new(@budget)

    @budget_snapshot = @request_change.get_budget_snapshot

    if params[:action_id]
      # редактирование изменения
      @request_change_action = RequestChangeAction.find(params[:action_id])
      if ['stat_zatr_edit', 'stat_zatr_create', 'set_budget_fot'].include?(@request_change_action.action_type)
        @request_change_action_content = @request_change_action.content
        @stat_zatr_id = @request_change_action_content["stat_zatr_id"]
      end
    elsif params[:stat_zatr_id] # todo      
      @request_change_action = RequestChangeAction.new
      @stat_zatr_id = params[:stat_zatr_id]
    elsif params[:do]
      # создание нового изменения
      @request_change_action = RequestChangeAction.new
      @request_change_action.request_change_id = @request_change.id
      @request_change_action.action_type = params[:do]
      @request_change_action.init_json
    end

  end

  def proceed
    @request_change.proceed(current_user)
    redirect_to @request_change
  end

  def delete_action
    @request_change_action = RequestChangeAction.find(params[:action_id])
    @request_change_action.destroy
    redirect_to @request_change_action.request_change
  end

  def set_action
    json_content = {}

    if params[:action_id]
      # EDIT
      @request_change_action = RequestChangeAction.find(params[:action_id])
    else
      # NEW
      @request_change_action = RequestChangeAction.new
      @request_change_action.request_change_id = @request_change.id
      @request_change_action.action_type = params[:do]
    end

    months = {}
    if @request_change_action.action_type == 'stat_zatr_edit'
      params["months"].each do |m|
        summa  = params["summa_#{m}"]
        beznal = params["beznal_#{m}"] || '0'
        months[m] = [summa, beznal]
      end

      json_content[:stat_zatr_id] = if @request_change_action.new_record?
        params[:stat_zatr_id]
      else
        @request_change_action.content["stat_zatr_id"]
      end
    elsif @request_change_action.action_type == 'stat_zatr_create'
      (1..12).to_a.each do |m|
        if params["summa_#{m}"].to_i > 0
          summa  = params["summa_#{m}"]
          beznal = params["beznal_#{m}"] || '0'
          months[m] = [summa, beznal]
        end
      end
      json_content[:stat_zatr_name]    = params[:stat_zatr_name]
      json_content[:spr_stat_zatrs_id] = params[:spr_stat_zatrs_id]
    elsif @request_change_action.action_type == 'set_budget_fot'
      json_content[:budget_fot_delta]    = params[:budget_fot_delta]
    end

    json_content[:months] = months unless months.empty?

    @request_change_action.json_content = json_content.to_json
    @request_change_action.save

    redirect_to @request_change
  end

  def _old_set_action
    json_content = {}
    months = {}
    params["months"].each do |m|
      summa  = params["summa_#{m}"]
      beznal = params["beznal_#{m}"] || '0'
      months[m] = [summa, beznal]
    end

    json_content[:months] = months

    if params[:action_id]
      @request_change_action = RequestChangeAction.find(params[:action_id])
      json_content[:stat_zatr_id] = @request_change_action.content["stat_zatr_id"]
    else
      json_content[:stat_zatr_id] = params[:stat_zatr_id]
      @request_change_action = RequestChangeAction.new
      @request_change_action.request_change_id = @request_change.id
      @request_change_action.action_type  = 'stat_zatr_edit'
    end
    @request_change_action.json_content = json_content.to_json
    @request_change_action.save

    redirect_to @request_change
  end

  def new
    @request_change = RequestChange.new
    @request_change.budget_id = params[:budget_id]
  end

  def edit
  end

  def create
    if @request_change = RequestChange.create(request_change_params)
      edit_state = 'Редактируется'
      @request_change.state = edit_state
      @request_change.author_id = current_user.id
      @request_change.save
      RequestChangeHistory.log(@request_change.id, current_user.id, @request_change.state)
      redirect_to request_change_path(@request_change.id), success: 'Заявление успешно создан'
    else
      flash.now[:danger] = 'Ошибка'
      render :new
    end
  end

  def update
    if @request_change.update(request_change_params)
      redirect_to request_change_path(@request_change.id), success: 'Заявление успешно обновлено'
    else
      flash.now[:danger] = 'Ошибка'
      render :edit
    end
  end


  private
    def set_request_change
      _id = if params[:request_change] && params[:request_change][:id]
         params[:request_change][:id]
      elsif params[:request_change_id]
        params[:request_change_id]
      else
        params[:id]
      end
      @request_change = RequestChange.find(_id)
    end

  def request_change_params
    params.require(:request_change).permit(:name, :budget_id,)
  end
end