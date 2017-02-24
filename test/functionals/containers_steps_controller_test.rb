require 'test_plugin_helper'

module Containers
  class StepsControllerTest < ActionController::TestCase
    setup do
      stub_image_existance
      stub_registry_api
      @container = FactoryGirl.create(:container)
      @state = DockerContainerWizardState.create!
    end

    test 'wizard finishes with a redirect to the managed container' do
      Service::Containers.any_instance.expects(:start_container!).with(equals(@state))
        .returns(@container)
      put :update, { :wizard_state_id => @state.id,
                     :id => :environment,
                     :start_on_create => true,
                     :docker_container_wizard_states_environment => { :tty => false } },
          set_session_user

      assert_redirected_to container_path(:id => @container.id)
    end

    describe 'on image step' do
      setup do
        @compute_resource = FactoryGirl.create(:docker_cr)
        @create_options = { :wizard_state => @state,
                           :compute_resource_id => @compute_resource.id }
        @state.preliminary = DockerContainerWizardStates::Preliminary.create!(@create_options)
        DockerContainerWizardState.expects(:find).at_least_once.returns(@state)
      end

      test 'image show doesnot load katello' do
        get :show, { :wizard_state_id => @state.id, :id => :image }, set_session_user
        refute @state.image.katello?
        refute response.body.include?("katello") # this is code generated by katello partial
        docker_image = @controller.instance_eval do
          @docker_container_wizard_states_image
        end
        assert_equal @state.image, docker_image
      end

      describe 'submitting' do
        setup do
          @image_params = {
            docker_container_wizard_states_image: {
              repository_name: 'test',
              tag: 'test'
          }}
          @params = @image_params.merge({
            wizard_state_id: @state.id,
            id: :image,
          })
        end

        test 'has no errors if the image exists' do
          put :update, @params, set_session_user
          assert_valid @state.image
          assert css_select('#hub_image_search.has-error').size == 0
        end

        test 'shows an error when the image does not exist' do
          stub_image_existance(false)
          put :update, @params, set_session_user
          refute_valid @state.image
          assert_select '#hub_image_search.has-error'
        end
      end
    end

    test 'new container respects exposed_ports configuration' do
      environment_options = {
        :docker_container_wizard_state_id => @state.id
      }
      @state.environment = DockerContainerWizardStates::Environment.create!(environment_options)
      @state.environment.exposed_ports.create!(:key => '1654', :value => 'tcp')
      @state.environment.exposed_ports.create!(:key => '1655', :value => 'udp')
      get :show, { :wizard_state_id => @state.id, :id => :environment }, set_session_user
      assert response.body.include?("1654")
      assert response.body.include?("1655")

      # Load ExposedPort variables into container
      @state.environment.exposed_ports.each do |e|
        @container.exposed_ports.build :key => e.key,
                                       :value => e.value
      end
      # Check if parametrized value of container matches Docker API's expectations
      assert @container.parametrize.key? "ExposedPorts"
      assert @container.parametrize["ExposedPorts"].key? "1654/tcp"
      assert @container.parametrize["ExposedPorts"].key? "1655/udp"
    end

    test 'new container respects dns configuration' do
      environment_options = {
        :docker_container_wizard_state_id => @state.id
      }
      @state.environment = DockerContainerWizardStates::Environment.create!(environment_options)
      @state.environment.dns.create!(:key => '18.18.18.18')
      @state.environment.dns.create!(:key => '19.19.19.19')
      get :show, { :wizard_state_id => @state.id, :id => :environment }, set_session_user
      assert response.body.include?("18.18.18.18")
      assert response.body.include?("19.19.19.19")

      # Load Dns variables into container
      @state.environment.dns.each do |e|
        @container.dns.build :key => e.key
      end
      # Check if parametrized value of container matches Docker API's expectations
      assert @container.parametrize.key? "HostConfig"
      assert @container.parametrize["HostConfig"].key? "Dns"
      assert @container.parametrize["HostConfig"].value? ["18.18.18.18", "19.19.19.19"]
    end

    test "does not create a container with 2 exposed ports with the same key" do
      environment_options = {
          :docker_container_wizard_state_id => @state.id
      }
      @state.environment = DockerContainerWizardStates::Environment.new(environment_options)
      @state.environment.exposed_ports.new(:key => '1654', :value => 'tcp')
      @state.environment.exposed_ports.new(:key => '1654', :value => 'udp')
      refute_valid @state
      assert_equal "Please ensure the following parameters are unique", @state.errors[:'environment.exposed_ports'].first
    end
  end
end
