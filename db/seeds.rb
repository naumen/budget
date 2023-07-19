# to reload:
# $ rake db:reset DISABLE_DATABASE_ENVIRONMENT_CHECK=1

f_year = 2023

admin = User.create!( name: "Admin", login: "admin", is_admin: true)


city_ekb  = City.create( id: 2, name: "Екатеринбург")
city_msk  = City.create( id: 1, name: "Москва")

location_in_ekb = Location.create( id: 13, city: city_ekb, name: 'БЦ 1')
location_in_msk = Location.create( id: 21, city: city_msk, name: "БЦ 2")

cfo1         = Cfo.create( name: "ЦФО1")


budget_type1 = BudgetType.create( name: "Тип бюджета1" )
               BudgetType.create( name: "Инвестиционный компании" )
               BudgetType.create( name: "Инвестиционный направления" )

SprStatZatr.create( name: "ПРЕМИИ")
SprStatZatr.create( name: "Резерв на ФОТ")

# =============== budgets

budget_root = Budget.create(
  id: 90001,
  name:   "Бюджет корневой",
  state:  "Черновик",
  f_year: f_year,
  cfo: cfo1,
  budget_type: budget_type1,
  owner: admin
)

budget1 = Budget.create(
  name:   "Бюджет1",
  state:  "Черновик",
  parent: budget_root,
  f_year: f_year,
  cfo: cfo1,
  budget_type: budget_type1,
  owner: admin
)

sale_channel = SaleChannel.create( name: 'Канал продаж1')
sale = Sale.create( budget: budget1,
                    sale_channel: sale_channel,
                    owner: admin,
                    quarter: 4,
                    name: 'Продажи',
                    summ: 1_000_000,
                    f_year: budget1.f_year
                  )

# =============== state_units

state_unit_ekb = StateUnit.create(
  budget: budget1,
  user:   admin,
  f_year: f_year,
  rate: 1.0,
  position: "Должность",
  division: "Отдел",
  location: location_in_ekb
)

# fzp
(1..12).to_a.each do |month|
  Salary.create(
    state_unit: state_unit_ekb,
    month:  month, 
    f_year: f_year,
    summ:   50000
  )
end
