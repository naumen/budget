require 'test_helper'

class NormativeTest < ActiveSupport::TestCase

  def setup
    @normativ_it_base = normativs(:normativ_it_base)
  end

  test "exists and class" do
    assert_instance_of Normativ, @normativ_it_base
  end

  test "naklad" do
    assert_equal 2, @normativ_it_base.naklads.size
  end

  # test "the truth" do
  #   assert true
  # end
end
