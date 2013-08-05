require 'test_helper'

class PickemPicksControllerTest < ActionController::TestCase
  setup do
    @pickem_pick = pickem_picks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pickem_picks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pickem_pick" do
    assert_difference('PickemPick.count') do
      post :create, pickem_pick: { game_id: @pickem_pick.game_id, team_id: @pickem_pick.team_id, user_id: @pickem_pick.user_id, week: @pickem_pick.week, year: @pickem_pick.year }
    end

    assert_redirected_to pickem_pick_path(assigns(:pickem_pick))
  end

  test "should show pickem_pick" do
    get :show, id: @pickem_pick
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @pickem_pick
    assert_response :success
  end

  test "should update pickem_pick" do
    put :update, id: @pickem_pick, pickem_pick: { game_id: @pickem_pick.game_id, team_id: @pickem_pick.team_id, user_id: @pickem_pick.user_id, week: @pickem_pick.week, year: @pickem_pick.year }
    assert_redirected_to pickem_pick_path(assigns(:pickem_pick))
  end

  test "should destroy pickem_pick" do
    assert_difference('PickemPick.count', -1) do
      delete :destroy, id: @pickem_pick
    end

    assert_redirected_to pickem_picks_path
  end
end
