require 'test_plugin_helper'

class ContainersServiceTest <  ActiveSupport::TestCase
  setup do
    @state = DockerContainerWizardState.create! do |s|
      s.build_preliminary(:compute_resource_id => FactoryGirl.create(:docker_cr).id,
                          :locations           => [taxonomies(:location1)],
                          :organizations       => [taxonomies(:organization1)])
      s.build_image(:repository_name => 'test', :tag => 'test')
      s.build_configuration(:name => 'test', :command => '/bin/bash')
      s.build_environment(:tty => false)
    end
  end

  test 'removes current state after container creation task is scheduled' do
    ForemanTasks.expects(:async_task).returns(true)
    assert_equal DockerContainerWizardState.where(:id => @state.id).count, 1
    ForemanDocker::Service::Containers.new.start_container!(@state)
    assert_equal DockerContainerWizardState.where(:id => @state.id).count, 0
  end
end
