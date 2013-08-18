require 'test_helper'

class StadiumsControllerTest < ActionController::TestCase
  setup do
    @stadium = stadiums(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stadiums)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stadium" do
    assert_difference('Stadium.count') do
      post :create, stadium: { grass_type: @stadium.grass_type, location: @stadium.location, stadium_type: @stadium.stadium_type, time_zone: @stadium.time_zone }
    end

    assert_redirected_to stadium_path(assigns(:stadium))
  end

  test "should show stadium" do
    get :show, id: @stadium
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @stadium
    assert_response :success
  end

  test "should update stadium" do
    put :update, id: @stadium, stadium: { grass_type: @stadium.grass_type, location: @stadium.location, stadium_type: @stadium.stadium_type, time_zone: @stadium.time_zone }
    assert_redirected_to stadium_path(assigns(:stadium))
  end

  test "should destroy stadium" do
    assert_difference('Stadium.count', -1) do
      delete :destroy, id: @stadium
    end

    assert_redirected_to stadiums_path
  end
end
