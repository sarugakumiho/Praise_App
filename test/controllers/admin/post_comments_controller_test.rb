require "test_helper"

class Admin::PostCommentsControllerTest < ActionDispatch::IntegrationTest
  test "should get destroy" do
    get admin_post_comments_destroy_url
    assert_response :success
  end
end
