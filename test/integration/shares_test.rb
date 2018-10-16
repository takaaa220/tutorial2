require 'test_helper'

class SharesTest < ActionDispatch::IntegrationTest
  def setup
    @micropost = microposts(:oh)
    @user = users(:michael)
    log_in_as(@user)
  end

  test "retweet a micropost" do
    assert_difference "Share.count", 1 do
      post shares_path, params: { micropost_id: @micropost.id}
    end
  end

  test "unretweet a micropost" do
    @micropost.retweet(@user)
    @share = @user.shares.find_by(user_id: @user.id)
    assert_difference "Share.count", -1 do
      delete share_path(@share)
    end
  end

  test "microposts retweeted by user should display in profile pages" do
    log_in_as(@user)
    get user_path(@user)
    assert_template "users/show"
    assert_no_match @micropost.content, response.body
    @micropost.retweet(@user)
    get user_path(@user)
    # userがリツイートした投稿が存在する
    assert_match @micropost.content, response.body
    @micropost.unretweet(@user)
    get user_path(@user)
    assert_no_match @micropost.content, response.body
  end

  test "micropost retweeted by user should display in feed" do
    log_in_as(@user)
    get root_path
    assert_no_match @micropost.content, response.body
    @micropost.retweet(@user)
    get root_path
    assert_match @micropost.content, response.body
    # michaelをフォローしているユーザのFeedにも表示
    log_in_as(users(:lana))
    get root_path
    assert_match @micropost.content, response.body
    # michaelのページに表示
    get user_path(@user)
    assert_match @micropost.content, response.body
    log_in_as(@user)
    @micropost.unretweet(@user)
    get root_path
    assert_no_match @micropost.content, response.body
    log_in_as(users(:lana))
    get root_path
    assert_no_match @micropost.content, response.body
    get user_path(@user)
    assert_no_match @micropost.content, response.body
  end
end
