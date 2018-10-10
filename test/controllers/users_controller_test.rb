require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other = users(:archer)
  end

  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end


  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch user_path(@user), params: { user: { name: @user.name, email: @user.email }}
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should not allow the admin attribute to be edited via the web" do
    log_in_as(@other)
    patch user_path(@other), params: { user: { password: @other.password,
                password_confirmation: @other.password, admin: true }}
    assert_not @other.reload.admin?
  end

  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other)
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do
    log_in_as(@other)
    patch user_path(@user), params: { user: { name: @user.name, email: @user.email }}
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference "User.count" do
      delete user_path(@other)
    end
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect destroy when logged in as non-admin" do
    log_in_as(@other)
    assert_no_difference "User.count" do
      delete user_path(@user)
    end
    assert_not flash.empty?
    assert_redirected_to root_url
  end
end
