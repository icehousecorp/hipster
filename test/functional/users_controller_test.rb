require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: { harvest_id: @user.harvest_id, harvest_password: @user.harvest_password, harvest_subdomain: @user.harvest_subdomain, harvest_username: @user.harvest_username, pivotal_id: @user.pivotal_id, pivotal_password: @user.pivotal_password, pivotal_username: @user.pivotal_username }
    end

    assert_redirected_to user_path(assigns(:user))
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    put :update, id: @user, user: { harvest_id: @user.harvest_id, harvest_password: @user.harvest_password, harvest_subdomain: @user.harvest_subdomain, harvest_username: @user.harvest_username, pivotal_id: @user.pivotal_id, pivotal_password: @user.pivotal_password, pivotal_username: @user.pivotal_username }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end
end
