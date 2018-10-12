require 'test_helper'

class MicropostTest < ActiveSupport::TestCase

  def setup
    @user = users(:michael)
    @micropost = @user.microposts.build(content: "Lorem")
  end

  test "should get valid" do
    assert @micropost.valid?
  end

  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test "content should be present" do
    @micropost.content = ""
    assert_not @micropost.valid?
  end

  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end

  test "order should be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end

  test "should like and unlike a micropost" do
    michael = users(:michael)
    zone = microposts(:zone)
    assert_not zone.iine?(michael)
    zone.iine(michael)
    assert zone.iine?(michael)
    zone.uuun(michael)
    assert_not zone.iine?(michael)
  end
end
