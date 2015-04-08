require 'test_plugin_helper'

module ForemanDocker
  module Service
    module Actions
      module Container
        class TestBase < ActiveSupport::TestCase
          include Dynflow::Testing
          include FactoryGirl::Syntax::Methods

          let(:container) { FactoryGirl.create(:container) }
        end

        class ProvisionTest < TestBase
          let(:action_class) { ForemanDocker::Service::Actions::Container::Provision }

          it 'plans pull and start' do
            action = create_action(action_class)
            action.stubs(:action_subject).with(container)
            plan_action(action, container)
            %w(Pull Start).each do |container_action|
              container_action = "ForemanDocker::Service::Actions::Container::#{container_action}"
              assert_action_planed_with(action, container_action.constantize, container)
            end
          end
        end

        class PullTest < TestBase
          let(:action_class) { ForemanDocker::Service::Actions::Container::Pull }

          it 'pulls the container image' do
            ::Container.expects(:find).returns(container)
            container.compute_resource.expects(:create_image).returns(true)
            action = create_action(action_class)
            action.stubs(:action_subject).with(container)
            plan_action(action, container)
            run_action(action) { |dynflow_action| dynflow_action.expects(:pull_docker_image) }
            action.pull_docker_image(container, []).join
          end
        end

        class StartTest < TestBase
          let(:action_class) { ForemanDocker::Service::Actions::Container::Start }

          it 'starts the container' do
            ::Container.expects(:find).returns(container)
            container.compute_resource.expects(:create_container).returns(container)
            action = create_action(action_class)
            action.stubs(:action_subject).with(container)
            plan_action(action, container)
            assert_run_phase(action)
            run_action(action)
          end
        end
      end
    end
  end
end
