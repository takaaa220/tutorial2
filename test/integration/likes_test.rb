require 'test_helper'

class LikesTest < ActionDispatch::IntegrationTest
  def setup
    @micropost = microposts(:orange)
    @user = users(:michael)
    log_in_as(@user)
  end

  test "likes page" do
    get likes_user_path(@user)
    assert_template "users/likes"
    assert_not @user.likes.empty?
    assert_match @user.likes.count.to_s, response.body
    @user.likes.each do |like|
      assert_select "a[href=?]", user_path(like.user)
    end
  end

  test "should iine a micropost with standard way" do
    assert_difference "@micropost.likes.count", 1 do
      post likes_path, params: { micropost_id: @micropost.id }
    end
  end

  test "should iine a micropost with Ajax" do
    assert_difference "@micropost.likes.count", 1 do
      post likes_path, xhr: true, params: { micropost_id: @micropost.id }
    end
  end

  test "should uuun a micropost with standard way" do
    @micropost.iine(@user)
    like = @micropost.likes.find_by(user_id: @user.id)
    assert_difference "@micropost.likes.count", -1 do
      delete like_path(like)
    end
  end

  test "should uuun a micropost with Ajax" do
    @micropost.iine(@user)
    like = @micropost.likes.find_by(user_id: @user.id)
    assert_difference "@micropost.likes.count", -1 do
      delete like_path(like), xhr: true
    end
  end
end
