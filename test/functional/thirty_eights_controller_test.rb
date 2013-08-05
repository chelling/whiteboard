require 'test_helper'

class ThirtyEightsControllerTest < ActionController::TestCase
  setup do
    @thirty_eight = thirty_eights(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:thirty_eights)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create thirty_eight" do
    assert_difference('ThirtyEight.count') do
      post :create, thirty_eight: { shares: @thirty_eight.shares, team_id: @thirty_eight.team_id, user_id: @thirty_eight.user_id, year: @thirty_eight.year }
    end

    assert_redirected_to thirty_eight_path(assigns(:thirty_eight))
  end

  test "should show thirty_eight" do
    get :show, id: @thirty_eight
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @thirty_eight
    assert_response :success
  end

  test "should update thirty_eight" do
    put :update, id: @thirty_eight, thirty_eight: { shares: @thirty_eight.shares, team_id: @thirty_eight.team_id, user_id: @thirty_eight.user_id, year: @thirty_eight.year }
    assert_redirected_to thirty_eight_path(assigns(:thirty_eight))
  end

  test "should destroy thirty_eight" do
    assert_difference('ThirtyEight.count', -1) do
      delete :destroy, id: @thirty_eight
    end

    assert_redirected_to thirty_eights_path
  end
end
