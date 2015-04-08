module ForemanDocker
  module Service
    module Actions
      module Container
        class Provision < ::Actions::EntryAction
          def plan(container)
            action_subject(container)

            sequence do
              plan_action(Container::Pull, container)
              plan_action(Container::Start, container)
            end
          end

          def humanized_name
            _('Provision container')
          end

          def finalize
            action_logger.info('Finished provisioning of Docker container')
          end
        end
      end
    end
  end
end
