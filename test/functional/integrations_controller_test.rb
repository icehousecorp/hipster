require 'test_helper'

class IntegrationsControllerTest < ActionController::TestCase
  setup do
    @integration = integrations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:integrations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create integration" do
    assert_difference('Project.count') do
      post :create, integration: { harvest_project_id: @integration.harvest_project_id, pivotal_project_id: @integration.pivotal_project_id }
    end

    assert_redirected_to project_path(assigns(:integration))
  end

  test "should show integration" do
    get :show, id: @integration
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @integration
    assert_response :success
  end

  test "should update integration" do
    put :update, id: @integration, integration: { harvest_project_id: @integration.harvest_project_id, pivotal_project_id: @integration.pivotal_project_id }
    assert_redirected_to project_path(assigns(:integration))
  end

  test "should destroy integration" do
    assert_difference('Project.count', -1) do
      delete :destroy, id: @integration
    end

    assert_redirected_to projects_path
  end
end
