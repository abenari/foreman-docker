module ForemanDocker
  module Service
    module Actions
      module Container
        class Start < ::Actions::EntryAction
          def plan(container)
            action_subject(container)
            plan_self(:container => container.id)
          end

          def run
            container = ::Container.find(input[:container])
            started = container.compute_resource.create_container(container.parametrize)
            if started
              container.update_attribute(:uuid, started.id)
              started
            else
              [container.compute_resource.errors[:base]]
            end
          end

          def humanized_name
            _('Start')
          end

          def finalize
            container = ::Container.find(input[:container])
            action_logger.info("[Docker] container #{container.name} successfully started")
          end
        end
      end
    end
  end
end
