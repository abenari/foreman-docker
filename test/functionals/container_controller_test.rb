require 'test_plugin_helper'

class ContainersControllerTest < ActionController::TestCase
  test 'redirect if Docker provider is not available' do
    get :index, {}, set_session_user
    assert_redirected_to new_compute_resource_path
  end

  test 'index if Docker resource is available' do
    Fog.mock!
    # Avoid rendering errors by not retrieving any container
    ComputeResource.any_instance.stubs(:vms).returns([])
    FactoryGirl.create(:docker_cr)
    get :index, {}, set_session_user
    assert_template 'index'
  end

  context 'deletions' do
    setup do
      Fog.mock!
      @container_resource = FactoryGirl.create(:docker_cr)
    end

    test 'unmanaged container redirects to containers index' do
      container = @container_resource.vms.first
      container.class.any_instance.expects(:destroy).returns(true)
      delete :destroy, { :compute_resource_id => @container_resource,
                         :id                  => container.id }, set_session_user
      assert_redirected_to containers_path
    end

    test 'managed container redirects to containers index' do
      managed_container = FactoryGirl.create(:container)
      delete :destroy, { :id => managed_container.id }, set_session_user
      assert_redirected_to containers_path
    end

    test 'managed container deletes container in docker' do
      managed_container = FactoryGirl.create(:container)
      ComputeResource.any_instance.expects(:destroy_vm).with(managed_container.uuid).returns(true)
      delete :destroy, { :id => managed_container.id }, set_session_user
    end
  end
end
