require 'test_helper'

class StateUnitTest < ActiveSupport::TestCase

  def setup
    @office_ekb           = locations(:office_ekb)
    @office_msk           = locations(:office_msk)
    @fo_user              = users(:fo_user)

    @state_unit           = state_units(:cfo_d_1_user1)
    @state_unit_next_year = @state_unit.clone_to_next_year
  end

  test "initial test" do
    assert @state_unit
    assert @state_unit_next_year

    assert_equal @office_ekb, @state_unit.location
    assert_equal @fo_user,    @state_unit.user

    assert_equal @state_unit_next_year.salaries.size, 12
    assert_equal @state_unit_next_year.salaries.where(month: 1).first.summ, 60_000
  end

  test "#clone_to_next_year" do
    assert_equal 2018, @state_unit.f_year
    assert_equal 2019, @state_unit_next_year.f_year

    assert_equal @state_unit.division,    @state_unit_next_year.division
    assert_equal @state_unit.position,    @state_unit_next_year.position
    assert_equal @state_unit.location_id, @state_unit_next_year.location_id
    assert_equal @state_unit.user_id,     @state_unit_next_year.user_id
  end

  test "#update state_unit" do
    @state_unit.location = @office_msk
    @state_unit.user_id  = nil
    @state_unit.staff_item_id  = nil
    @state_unit.save

    @state_unit_next_year = @state_unit.clone_to_next_year
    assert_equal @state_unit.location,           @office_msk
    assert_equal @state_unit_next_year.location, @office_msk
    assert_nil @state_unit_next_year.user_id
    assert_nil @state_unit_next_year.staff_item_id
  end

  test "#on_update_salary" do
    december_salary = @state_unit.salaries.where(month: 12).first
    december_salary.summ = 65_000
    december_salary.save

    @state_unit.on_update_salary

    assert_equal @state_unit_next_year.salaries.where(month: 1).first.summ, 65_000

    december_salary = @state_unit.salaries.where(month: 12).first
    december_salary.summ = 50_000
    december_salary.save
    assert_equal @state_unit_next_year.salaries.where(month: 1).first.summ, 65_000

  end

  # update salary


end
