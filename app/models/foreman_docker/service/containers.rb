module ForemanDocker
  module Service
    class Containers
      def errors
        @errors ||= []
      end

      def start_container!(wizard_state)
        container = ActiveRecord::Base.transaction do
          container = Container.new(wizard_state.container_attributes) do |r|
            # eagerly load environment variables
            state =
              DockerContainerWizardState.includes(:environment => [:environment_variables])
              .find(wizard_state.id)
            state.environment_variables.each do |environment_variable|
              r.environment_variables.build :name     => environment_variable.name,
                                            :value    => environment_variable.value,
                                            :priority => environment_variable.priority
            end
          end
          Taxonomy.enabled_taxonomies.each do |taxonomy|
            container.send(:"#{taxonomy}=", wizard_state.preliminary.send(:"#{taxonomy}"))
          end
          container.save!
          container
        end

        destroy_wizard_state(wizard_state)
        ForemanTasks.async_task(Service::Actions::Container::Provision, container)
        container
      end

      def destroy_wizard_state(wizard_state)
        wizard_state.destroy
        DockerContainerWizardState.destroy_all(["updated_at < ?", (Time.now - 24.hours)])
      end
    end
  end
end
