require 'test_helper'

class SprStatZatrTest < ActiveSupport::TestCase
  def setup
    @spr_stat_zatr_premii = spr_stat_zatrs(:premii)
  end

  test "exists and class" do
    assert_instance_of SprStatZatr, @spr_stat_zatr_premii
  end

  test "name PREMII" do
    assert_equal "ПРЕМИИ", @spr_stat_zatr_premii.name
  end

  test "get Premii" do
    premii = SprStatZatr.get_premii_item
    assert_equal premii, @spr_stat_zatr_premii
  end
end
