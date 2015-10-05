require 'test_helper'

class WordlistControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get get_wordlist" do
    get :get_wordlist
    assert_response :success
  end

end
