require 'test_helper'

class ConferenceControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get conference_show_url
    assert_response :success
  end

end
