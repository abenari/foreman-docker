require 'test_plugin_helper'

module Containers
  class StepsControllerTest < ActionController::TestCase
    setup do
      @container = FactoryGirl.create(:container)
    end

    test 'sets a docker repo and tag for a new container' do
      put :update, { :id => :image,
                     :repository => { :docker_registry_id => '',
                                      :name => 'centos' },
                     :container_id => @container.id,
                     :container => { :tag => 'latest' } }, set_session_user
      assert_response :found
      assert_redirected_to container_step_path(:container_id => @container.id,
                                               :id           => :configuration)
      assert_equal DockerRepository.find_by_name('centos'), @container.reload.repository
      assert_equal DockerTag.find_by_tag('latest'), @container.tag
    end

    context 'container creation' do
      setup do
        repository = FactoryGirl.create(:docker_repository,
                                        :name => 'centos')
        @container.update_attribute(:repository, repository)
        @container.update_attribute(:tag, FactoryGirl.create(:docker_tag, :repository => repository,
                                                                          :tag   => 'latest'))
      end

      test 'uuid of the created container is saved at the end of the wizard' do
        Fog.mock!
        fake_container = @container.compute_resource.send(:client).servers.first
        ForemanDocker::Docker.any_instance.expects(:create_container).returns(fake_container)
        put :update, { :id           => :environment,
                       :container_id => @container.id }, set_session_user
        assert_equal fake_container.id, Container.find(@container.id).uuid
      end

      test 'errors are displayed when container creation fails' do
        Docker::Container.expects(:create).raises(Docker::Error::DockerError, 'some error')
        put :update, { :id           => :environment,
                       :container_id => @container.id }, set_session_user
        assert_template 'environment'
        assert_match(/some error/, flash[:error])
      end
    end

    test 'wizard finishes with a redirect to the managed container' do
      get :show, { :id => :wicked_finish,
                   :container_id => @container.id }, set_session_user
      assert_redirected_to container_path(:id => @container.id)
    end
  end
end
