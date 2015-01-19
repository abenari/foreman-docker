module Containers
  class StepsController < ::ApplicationController
    include Wicked::Wizard
    include ForemanDocker::FindContainer

    steps :preliminary, :image, :configuration, :environment

    before_filter :find_state
    before_filter :build_state, :only => [:update]
    before_filter :set_form, :only => [:show]

    def show
      @container_resources = allowed_resources if step == :preliminary
      render_wizard
    end

    def update
      if step == wizard_steps.last
        create_container
      else
        render_wizard @state
      end
    end

    private

    def find_state
      @state = DockerContainerWizardState.find(params[:wizard_state_id])
    rescue ActiveRecord::RecordNotFound
      not_found
    end

    def build_state
      @state.send(:"build_#{step}", params[:"docker_container_wizard_states_#{step}"])
    end

    def set_form
      instance_variable_set(
          "@docker_container_wizard_states_#{step}",
          @state.send(:"#{step}") || @state.send(:"build_#{step}"))
    end

    def create_container
      @state.send(:"create_#{step}", params[:"docker_container_wizard_states_#{step}"])
      container = Service::Containers.start_container!(@state)
      if container.present?
        process_success(:object => container, :success_redirect => container_path(container))
      else
        @environment = @state.environment
        process_error(:object => @state.environment, :render => 'environment')
      end
    end
  end
end
