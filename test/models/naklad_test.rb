require 'test_helper'

class NakladTest < ActiveSupport::TestCase
  def setup
    @normativ_it_base_to_b_d_cfo_1 = naklads(:normativ_it_base_to_b_d_cfo_1)
  end

  test "test exists and class" do
    assert_instance_of Naklad, @normativ_it_base_to_b_d_cfo_1
  end

end
