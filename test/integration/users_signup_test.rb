require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end
  
  test "invalid signup information" do
    get signup_path
    assert_no_difference "User.count" do
      post users_path, params: {
        user: { name: "", email: "user@invald",
          password: "foo", password_confirmation: "bar" }}
    end
    assert_template "users/new"
    assert_select "div#error_explanation"
    assert_select "div.alert"
  end

  test "valid signup information with account activation" do
    get signup_path
    name = "test"
    email = "test@test.email"
    assert_difference "User.count", 1 do
      post users_path, params: { user: { name: name, email: email,
          password: "aaaaaa", password_confirmation: "aaaaaa" }}
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # 有効化していない状態でログイン
    log_in_as(user)
    assert_not is_logged_in?
    # トークンが不正
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # トークンは正しいがアドレスが無効
    get edit_account_activation_path(user.activation_token, email: "wrong")
    assert_not is_logged_in?
    # トークンが正しい
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template "users/show"
    assert_not flash.empty?
    assert is_logged_in?
  end
end
