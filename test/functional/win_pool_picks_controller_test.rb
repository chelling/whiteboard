require 'test_helper'

class WinPoolPicksControllerTest < ActionController::TestCase
  setup do
    @win_pool_pick = win_pool_picks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:win_pool_picks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create win_pool_pick" do
    assert_difference('WinPoolPick.count') do
      post :create, win_pool_pick: { starting_position: @win_pool_pick.starting_position, team_one_id: @win_pool_pick.team_one_id, team_three_id: @win_pool_pick.team_three_id, team_two_id: @win_pool_pick.team_two_id, user_id: @win_pool_pick.user_id, win_pool_league_id: @win_pool_pick.win_pool_league_id, year: @win_pool_pick.year }
    end

    assert_redirected_to win_pool_pick_path(assigns(:win_pool_pick))
  end

  test "should show win_pool_pick" do
    get :show, id: @win_pool_pick
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @win_pool_pick
    assert_response :success
  end

  test "should update win_pool_pick" do
    put :update, id: @win_pool_pick, win_pool_pick: { starting_position: @win_pool_pick.starting_position, team_one_id: @win_pool_pick.team_one_id, team_three_id: @win_pool_pick.team_three_id, team_two_id: @win_pool_pick.team_two_id, user_id: @win_pool_pick.user_id, win_pool_league_id: @win_pool_pick.win_pool_league_id, year: @win_pool_pick.year }
    assert_redirected_to win_pool_pick_path(assigns(:win_pool_pick))
  end

  test "should destroy win_pool_pick" do
    assert_difference('WinPoolPick.count', -1) do
      delete :destroy, id: @win_pool_pick
    end

    assert_redirected_to win_pool_picks_path
  end
end
