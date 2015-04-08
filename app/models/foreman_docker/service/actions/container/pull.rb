module ForemanDocker
  module Service
    module Actions
      module Container
        class Pull < ::Actions::EntryAction
          def plan(container)
            action_subject(container)
            plan_self(:container => container.id)
          end

          def run(event = nil)
            case event
            when :done # do nothing and move to next step
            when StandardError
              action_logger.error(event.message)
              action_logger.debug(event.backtrace.join("\n "))
              error!(event)
            else
              suspend do |suspended_action|
                pull_docker_image(::Container.find(input[:container]), suspended_action)
              end
            end
          end

          def pull_docker_image(container, suspended_action)
            Thread.new do
              begin
                container.compute_resource
                  .create_image(:fromImage => container.repository_pull_url)
                suspended_action << :done
              rescue => e
                # encapsulate e as Foreman::Exception
                suspended_action << e
              end
            end
          end

          def humanized_name
            _('Pull')
          end

          def finalize
            container = ::Container.find(input[:container])
            action_logger.info("[Docker] Finished pulling image #{container.repository_pull_url}")
          end
        end
      end
    end
  end
end
