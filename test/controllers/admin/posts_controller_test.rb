require "test_helper"

class Admin::PostsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get admin_posts_show_url
    assert_response :success
  end

  test "should get index" do
    get admin_posts_index_url
    assert_response :success
  end

  test "should get tags" do
    get admin_posts_tags_url
    assert_response :success
  end

  test "should get search" do
    get admin_posts_search_url
    assert_response :success
  end
end
