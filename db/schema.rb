# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20210803142517) do

  create_table "budget_histories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "budget_id"
    t.string "state"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "budget_metriks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "budget_id"
    t.integer "metrik_id"
    t.decimal "value", precision: 15, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sale_channel_id"
    t.string "city"
    t.decimal "value_own", precision: 15, scale: 2
    t.datetime "archived_at"
    t.integer "f_year"
    t.index ["budget_id", "metrik_id", "archived_at"], name: "index_budget_metriks_on_budget_id_and_metrik_id_and_archived_at"
  end

  create_table "budget_params", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "budgets_report_access"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "budget_settings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "budget_setting_type_id"
    t.integer "settings_params_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "budget_signs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "budget_id"
    t.integer "user_id"
    t.integer "s_order"
    t.integer "attempt_num"
    t.boolean "is_current_attempt"
    t.integer "result"
    t.timestamp "result_date"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "budget_snapshots", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "budget_id"
    t.text "json_content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "budget_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "budgets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "target"
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.integer "f_year"
    t.integer "budget_type_id"
    t.integer "cfo_id"
    t.integer "cfo_type_id"
    t.integer "user_id"
    t.date "budget_create"
    t.string "name"
    t.string "state"
    t.string "currency"
    t.float "plan_marga", limit: 24, default: 0.0
    t.float "plan_invest_marga", limit: 24
    t.float "nepredv", limit: 24
    t.float "all_zatrats_summ", limit: 24, default: 0.0
    t.float "all_dohods_summ", limit: 24, default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "prev_budget_id"
    t.integer "next_budget_id"
    t.float "itogo_usage", limit: 24, default: 0.0
    t.date "archived"
    t.float "itogo_in", limit: 24
    t.string "budget_info"
    t.index ["lft"], name: "index_budgets_on_lft"
    t.index ["parent_id"], name: "index_budgets_on_parent_id"
    t.index ["rgt"], name: "index_budgets_on_rgt"
  end

  create_table "cfos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "manager_id"
    t.date "archived_date"
    t.integer "curator_id"
    t.date "archive_date"
  end

  create_table "cities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "divisions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.integer "f_year"
    t.integer "budget_id"
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "chief_id"
    t.boolean "is_department"
  end

  create_table "documents", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "filename"
    t.string "content_type"
    t.integer "investment_project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "invest_loan_id"
    t.string "original_file_name"
    t.datetime "archived_at"
    t.integer "owner_id"
    t.string "owner_type"
  end

  create_table "invest_loans", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "use_budget_id"
    t.integer "credit_budget_id"
    t.string "currency"
    t.decimal "summ", precision: 15, scale: 2
    t.float "interest_rate", limit: 24
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.integer "document_id"
  end

  create_table "investment_projects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.integer "from_budget_id"
    t.integer "to_budget_id"
    t.string "currency"
    t.decimal "summ", precision: 15, scale: 2
    t.integer "document_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "f_year"
    t.string "naudoc_link"
  end

  create_table "locations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.integer "city_id"
    t.date "archived"
  end

  create_table "metriks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "code"
  end

  create_table "motivations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "f_year"
    t.integer "user_id"
    t.string "name"
    t.integer "author"
    t.integer "budget_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.integer "document_id"
    t.integer "stat_zatr_id"
  end

  create_table "naklads", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "budget_id"
    t.float "norm", limit: 53
    t.integer "normativ_id"
    t.decimal "summ", precision: 15, scale: 2
    t.decimal "weight", precision: 15, scale: 3
    t.string "naklad_method"
    t.integer "sales_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "f_year"
    t.datetime "archived_at"
    t.index ["budget_id"], name: "index_naklads_on_budget_id"
    t.index ["normativ_id"], name: "index_naklads_on_normativ_id"
  end

  create_table "normativ_cores", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "fin_year"
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "normativ_params", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "normativ_core_id"
    t.string "name"
    t.float "norm", limit: 53
    t.text "description"
    t.integer "budget_id"
    t.integer "metriks_id"
    t.string "comment"
    t.integer "normativ_type_id"
    t.decimal "diff_in_rub", precision: 15, scale: 2
    t.decimal "diff_in_proc", precision: 15, scale: 2
    t.datetime "opened_at"
    t.datetime "closed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "city"
    t.index ["budget_id"], name: "index_normativ_params_on_budget_id"
    t.index ["normativ_core_id"], name: "index_normativ_params_on_normativ_core_id"
  end

  create_table "normativ_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "normativs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.decimal "norm", precision: 13, scale: 4
    t.text "description"
    t.integer "budget_id"
    t.integer "metrik_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "comment"
    t.integer "normativ_type_id"
    t.float "diff_in_rub", limit: 24
    t.float "diff_in_proc", limit: 24
    t.integer "f_year"
    t.integer "normativ_in_prev_year_id"
    t.text "sostav_zatrat"
  end

  create_table "positions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
  end

  create_table "repayment_loans", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "invest_loan_id"
    t.integer "fin_year"
    t.decimal "summ", precision: 15, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "from_budget_id"
    t.integer "to_budget_id"
  end

  create_table "request_change_actions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "request_change_id"
    t.string "action_type"
    t.text "json_content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "request_change_histories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "request_change_id"
    t.string "state"
    t.integer "user_id"
    t.string "timestamps"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "request_change_signs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "request_change_id"
    t.integer "user_id"
    t.integer "s_order"
    t.integer "attempt_num"
    t.boolean "is_current_attempt"
    t.integer "result"
    t.timestamp "result_date"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "request_changes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.integer "author_id"
    t.integer "budget_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "budget_snapshot_id"
    t.string "state"
  end

  create_table "salaries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "state_unit_id"
    t.integer "month"
    t.decimal "summ", precision: 15, scale: 2
    t.integer "f_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "staff_item_id"
    t.index ["state_unit_id"], name: "index_salaries_on_state_unit_id"
  end

  create_table "sale_channels", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "archived_date"
    t.integer "f_year"
  end

  create_table "sales", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "budget_id"
    t.integer "sale_channel_id"
    t.integer "user_id"
    t.integer "quarter"
    t.decimal "summ", precision: 15, scale: 2, default: "0.0"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "f_year"
    t.boolean "is_with_nds", default: false
    t.index ["budget_id"], name: "index_sales_on_budget_id"
  end

  create_table "setting_params", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.integer "setting_type"
    t.integer "budget_setting_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "snapshots", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "database_name"
    t.string "current_folder"
    t.boolean "active"
    t.float "filling_money", limit: 24
    t.float "def_prof_money", limit: 24
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "spr_cfo_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "spr_locations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "city"
    t.datetime "archive_date"
    t.integer "city_id"
  end

  create_table "spr_stat_zatrs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
  end

  create_table "staff_item_salaries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "f_month"
    t.integer "f_year"
    t.integer "salary"
    t.integer "staff_item_id"
    t.date "archive_date"
    t.date "reserve_date"
    t.integer "staff_request_id"
    t.date "date_closed"
  end

  create_table "staff_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "position_id"
    t.integer "division_id"
    t.integer "user_staff_id"
    t.integer "location_id"
    t.float "koeff", limit: 24
  end

  create_table "stat_zatrs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "spr_stat_zatr_id"
    t.integer "budget_id"
    t.string "name"
    t.decimal "all_summ", precision: 15, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "spr_stat_zatrs_id"
    t.integer "f_year"
    t.index ["budget_id"], name: "index_stat_zatrs_on_budget_id"
    t.index ["spr_stat_zatrs_id"], name: "index_stat_zatrs_on_spr_stat_zatrs_id"
  end

  create_table "state_units", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "budget_id"
    t.integer "user_id"
    t.integer "f_year"
    t.float "rate", limit: 24
    t.string "position"
    t.string "division"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "location_id"
    t.date "archive_date"
    t.integer "staff_item_id"
    t.date "date_closed"
    t.boolean "is_bind", default: false
    t.integer "parent_id"
    t.index ["budget_id"], name: "index_state_units_on_budget_id"
  end

  create_table "user_staffs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id"
    t.integer "staff_item_id"
    t.date "date_from"
    t.date "date_closed"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "login"
    t.boolean "is_admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "employment_term"
  end

  create_table "users_roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "budget_id"
    t.integer "user_id"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "budget_id"], name: "index_users_roles_on_user_id_and_budget_id"
    t.index ["user_id", "role"], name: "index_users_roles_on_user_id_and_role"
  end

  create_table "zatrats", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "stat_zatr_id"
    t.integer "month"
    t.decimal "summ", precision: 15, scale: 2
    t.boolean "nal_beznal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "f_year"
    t.index ["stat_zatr_id"], name: "index_zatrats_on_stat_zatr_id"
  end

end
