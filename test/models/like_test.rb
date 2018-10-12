require 'test_helper'

class LikeTest < ActiveSupport::TestCase

  def setup
    @like = Like.new(user_id: users(:michael).id, micropost_id: microposts(:ants).id)
  end

  test "should get valid" do
    assert @like.valid?
  end

  test "user_id should be present" do
    @like.user_id = nil
    assert_not @like.valid?
  end

  test "micropost_id should be present" do
    @like.micropost_id = nil
    assert_not @like.valid?
  end

end
