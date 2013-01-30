require 'test_helper'

class PersonMappingsControllerTest < ActionController::TestCase
  setup do
    @person_mapping = person_mappings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:person_mappings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create person_mapping" do
    assert_difference('PersonMapping.count') do
      post :create, person_mapping: { email: @person_mapping.email, harvest_id: @person_mapping.harvest_id, pivotal_name: @person_mapping.pivotal_name }
    end

    assert_redirected_to person_mapping_path(assigns(:person_mapping))
  end

  test "should show person_mapping" do
    get :show, id: @person_mapping
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @person_mapping
    assert_response :success
  end

  test "should update person_mapping" do
    put :update, id: @person_mapping, person_mapping: { email: @person_mapping.email, harvest_id: @person_mapping.harvest_id, pivotal_name: @person_mapping.pivotal_name }
    assert_redirected_to person_mapping_path(assigns(:person_mapping))
  end

  test "should destroy person_mapping" do
    assert_difference('PersonMapping.count', -1) do
      delete :destroy, id: @person_mapping
    end

    assert_redirected_to person_mappings_path
  end
end
