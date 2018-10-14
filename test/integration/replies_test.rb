require 'test_helper'

class RepliesTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @follower = users(:take) # michaelをフォローしてる
    @unfollower = users(:taki)
    @micropost = microposts(:van)
  end

  test "reply to other user" do
    log_in_as(@user)
    get micropost_path(@micropost)
    to_user = users(:takashi)
    assert_template "microposts/show"
    content = "@#{to_user.name} hello"
    post microposts_path, params: { micropost: { content: content } }
    follow_redirect!
    # 投稿者のフィードには存在する
    assert_match content, response.body
    # 返信先のユーザのフィードには存在する
    log_in_as(to_user)
    get root_path
    assert_match content, response.body
    # フォローされているユーザからも見えない
    log_in_as(@follower)
    get root_path
    assert_no_match content, response.body
    # フォローされていないユーザからも見えない
    log_in_as(@unfollower)
    get root_path
    assert_no_match content, response.body
  end
end
