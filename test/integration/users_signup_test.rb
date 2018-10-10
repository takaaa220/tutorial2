require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

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

  test "valid signup information" do
    get signup_path
    name = "test"
    email = "test@test.email"
    assert_difference "User.count", 1 do
      post users_path, params: { user: { name: name, email: email,
          password: "aaaaaa", password_confirmation: "aaaaaa" }}
    end
    follow_redirect!
    assert_template "users/show"
    assert_not flash.empty?
  end
end
