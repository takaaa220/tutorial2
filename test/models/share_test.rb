require 'test_helper'

class ShareTest < ActiveSupport::TestCase

  def setup
    #@share = Share.create(user_id: 1, micropost_id: 4)
    @share = shares(:one)
  end

  test "should be valid" do
    assert @share.valid?
  end

  test "user_id should be present" do
    @share.user_id = nil
    assert_not @share.valid?
  end

  test "micropost_id should be present" do
    @share.micropost_id = nil
    assert_not @share.valid?
  end
end
