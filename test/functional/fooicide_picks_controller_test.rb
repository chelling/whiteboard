require 'test_helper'

class FooicidePicksControllerTest < ActionController::TestCase
  setup do
    @fooicide_pick = fooicide_picks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:fooicide_picks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create fooicide_pick" do
    assert_difference('FooicidePick.count') do
      post :create, fooicide_pick: { game_id: @fooicide_pick.game_id, team_id: @fooicide_pick.team_id, user_id: @fooicide_pick.user_id, week: @fooicide_pick.week, year: @fooicide_pick.year }
    end

    assert_redirected_to fooicide_pick_path(assigns(:fooicide_pick))
  end

  test "should show fooicide_pick" do
    get :show, id: @fooicide_pick
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @fooicide_pick
    assert_response :success
  end

  test "should update fooicide_pick" do
    put :update, id: @fooicide_pick, fooicide_pick: { game_id: @fooicide_pick.game_id, team_id: @fooicide_pick.team_id, user_id: @fooicide_pick.user_id, week: @fooicide_pick.week, year: @fooicide_pick.year }
    assert_redirected_to fooicide_pick_path(assigns(:fooicide_pick))
  end

  test "should destroy fooicide_pick" do
    assert_difference('FooicidePick.count', -1) do
      delete :destroy, id: @fooicide_pick
    end

    assert_redirected_to fooicide_picks_path
  end
end
