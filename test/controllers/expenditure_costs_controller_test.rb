require "test_helper"

class ExpenditureCostsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get expenditure_costs_new_url
    assert_response :success
  end

  test "should get create" do
    get expenditure_costs_create_url
    assert_response :success
  end

  test "should get index" do
    get expenditure_costs_index_url
    assert_response :success
  end

  test "should get edit" do
    get expenditure_costs_edit_url
    assert_response :success
  end

  test "should get update" do
    get expenditure_costs_update_url
    assert_response :success
  end

  test "should get destroy" do
    get expenditure_costs_destroy_url
    assert_response :success
  end
end
