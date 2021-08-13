 Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace 'api' do
    namespace 'v1' do
      resources :cities
      resources :cfos
      resources :offices
      resources :divisions
      resources :positions
      resources :staff_items
      get "state_units/bind" => "state_units#bind"
      get "state_units/by_staff_item" => "state_units#by_staff_item"
      get "users/user_salaries" => "users#user_salaries"
      resources :state_units
      resources :users
      resources :budgets
    end
    namespace 'v2' do
      resources :cities
      resources :cfos
      resources :offices
      resources :divisions
      resources :positions
      resources :staff_items
      post "state_units/bind"   => "state_units#bind_unbind_v2", defaults: { do_action: "bind" }
      post "state_units/unbind" => "state_units#bind_unbind_v2", defaults: { do_action: "unbind" }
      resources :state_units
      resources :users
      resources :budgets
    end
  end

  get  "budget/:id/fot_edit" => "budgets#fot_edit"
  post "budget/:id/fot_edit" => "budgets#fot_edit"

  get 'state_units/:state_unit_id/redirect' => "state_units#redirect"

  get 'state_units/not_cloned' => "state_units#not_cloned"
  get 'state_units/clone_to_2021' => "state_units#clone_to_2021"

  get  "budgets/report" => 'budgets#report'
  post "budgets/report" => 'budgets#report'
  get  "budgets/report2" => 'budgets#report2'
  get  "budgets/:budget_id/report_by_months" => 'budgets#report_by_months'
  get  "budgets/budget_report_row/:budget_id" => 'budgets#budget_report_row'
  get  "budget_confirmations" => 'budgets#confirmations'
  get  "budget/:id/state_unit_salary" => "budgets#state_unit_salary"
  get  "budget_report/access_users"   => "budgets#report_access_users"
  post "budget_report/add_access_user" => "budgets#report_add_access_users"
  post "budget_report/del_access_user" => "budgets#report_del_access_users"

  get  "state_units/location_compare" => 'state_units#location_compare'
  get  "state_units/division_compare" => 'state_units#division_compare'

  patch "budgets/:id/load_doc" => 'budgets#load_doc'

  resources :budgets
  resources :sales
  resources :sale_channels
  resources :stat_zatrs
  resources :users_roles, except:[:show]
  resources :zatrats, except: [:show, :index]
  resources :salaries
  resources :divisions, only: [:index, :show, :update]
  post 'divisions/update_list' => 'divisions#update_list'


  resources :normativs
  resources :investment_projects
  resources :documents, only: [:show, :destroy]
  resources :budget_metriks

  resources :request_changes do
    patch "set_action"
    post  "proceed"
    get   "delete_action"
  end

  post  'request_change/:id/set_state' => 'request_changes#set_state'
  post  'request_change/:id/sign'      => 'request_changes#sign'
  post  'request_change/:id/create_save_action' => 'request_changes#create_save_action'

#   resources :request_change_actions
#   get  'request_change/show/:id'    => 'request_change#show'

  resources :invest_loans
  resources :repayment_loans
  resources :snapshots do
    post 'backups', on: :member
  end

  # users
  get 'users/'       => 'budgets#users'
  get 'login_as/:id' => 'budgets#login_as'

  get  'staff_requests/get_divisions'   => 'staff_requests#get_divisions'
  get  'staff_requests/staff'           => 'staff_requests#staff'
  get  'staff_requests/staff_show/:division_id'      => 'staff_requests#staff_show'
  get  'staff_requests/get_staff_items' => 'staff_requests#get_staff_items'
  post 'staff_requests/set_change'      => 'staff_requests#set_change'
  get  'staff_requests/change/delete/:change_id' => 'staff_requests#delete_change'
  resources :staff_requests

  get  'help/budget_fot'    => 'help#budget_fot'

  get  'import'    => 'import#index'
  post 'do_import' => 'import#do_import'
  get  'budget/info'    => 'budgets#info'
  get  'budgets_graph'  => 'budgets#graph'
  get  'budgets/reload_from_2018/:budget_id'    => 'budgets#reload_from_2018'
  get  'budgets/delete/:id'    => 'budgets#delete'
  get  'budgets/:id/metrik_changes'    => 'budgets#metrik_changes'

  # fot
  get  'budgets/:id/fot'  => 'budgets#fot2'
  get  'budgets/:id/fot2' => 'budgets#fot2'
  get  'budgets/:id/fot_summary'  => 'budgets#fot_summary'
  get  'budgets/:id/fot_salaries' => 'budgets#fot_salaries'
  get  'budgets/:id/fot_items'    => 'budgets#fot_items'
  get  'budgets/:id/fot_budgets'  => 'budgets#fot_budgets'

  get 'budget_new_staff_items' => 'budgets#new_staff_items'
  get 'budget/clone_state_unit/:id' => 'budgets#clone_state_unit'

  # info_normativ_avg
  get  'budgets/:id/info_normativ_avg'  => 'budgets#info_normativ_avg'
  
  post 'budgets/:id/set_change' => 'budgets#set_change'
  post 'budgets/:id/fot_delete_state_unit'   => 'budgets#fot_delete_state_unit'
  
  get  'budgets_fot'    => 'budgets#fot'

  get  'budgets/clone_budget_to_next_year/:budget_id'    => 'budgets#clone_budget_to_next_year'
  post 'budgets/:id/set_state' => 'budgets#set_state'
  post 'budgets/:id/sign'      => 'budgets#sign'

  get   'zatrats/report_zp' => 'zatrats#report_zp'
  get   'zatrats/report'    => 'zatrats#report'


  resources :motivations


  ### Справочники ###
  resources :budget_types
  resources :spr_cfo_types
  resources :spr_stat_zatrs
  resources :locations
  resources :state_units
  resources :metriks
  resources :normativ_types

  get     'staff_item/:id/salaries' => 'staff_item#salaries', as: 'staff_item_salaries'

  get     'login'         => 'users#login'
  post    'login'         => 'users#authorization'
  get     'logins'        => 'users#index'
  get     'logout'        => 'users#logout'

  get     'test_data'     => 'salaries#test_data'

  get     'naklamatr'     => 'normativs#naklamatr'
  post    'naklamatr'     => 'normativs#naklads_create'

  post  'destroy_zatrats' => 'zatrats#destroy_zatrats'

  post    'fixzartats'    => 'stat_zatrs#create_fix_zatrats'

  get     'settings'      => 'budgets#settings'
  post    'settings'      => 'budgets#settings_save'

  post  "budget_setting"  => 'budgets#budget_setting'

  get     'switch_snapshot'            => 'databases#switch'
  get     'switch_snapshot_reset'      => 'databases#switch_reset'

  get     'changes'      => 'changes#index'

  root to: 'budgets#index'
 end
