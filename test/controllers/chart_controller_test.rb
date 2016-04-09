require 'test_helper'

class ChartControllerTest < ActionController::TestCase
  test "should get basic" do
    get :basic
    assert_response :success
  end

  test "should get premium" do
    get :premium
    assert_response :success
  end

end
