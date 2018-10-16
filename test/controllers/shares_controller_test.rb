require 'test_helper'

class SharesControllerTest < ActionDispatch::IntegrationTest

  test "create should redirect when no-logged-user" do
    assert_no_difference "Share.count" do
      post shares_path
    end
    assert_redirected_to login_url
  end

  test "destroy should redirect when no-logged-user" do
    assert_no_difference "Share.count" do
      delete share_path(shares(:one))
    end
    assert_redirected_to login_url
  end
end
