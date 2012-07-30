require 'test_helper'

class AssetsControllerTest < ActionController::TestCase
  test "should get tmdb" do
    get :tmdb
    assert_response :success
  end

end
