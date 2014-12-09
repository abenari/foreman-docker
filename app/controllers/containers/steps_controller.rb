module Containers
  class StepsController < ::ApplicationController
    include Wicked::Wizard

    steps :preliminary, :image, :configuration, :environment
    before_filter :find_container

    def show
      case step
      when :preliminary
        @container_resources = ComputeResource.select { |cr| cr.provider == 'Docker' }
      end
      render_wizard
    end

    # rubocop:disable Metrics/MethodLength
    def update
      case step
      when :preliminary
        @container.update_attribute(:compute_resource_id, params[:container][:compute_resource_id])
      when :image
        repo = update_or_create_repo(params[:repository][:name], params[:repository][:registry_id])
        tag = DockerTag.find_or_create_by_tag_and_docker_repository_id!(params[:container][:tag],
                                                                        repo.id)
        @container.update_attributes!(
            :repository => repo,
            :tag => tag
        )
      when :configuration
        @container.update_attributes(params[:container])
      when :environment
        @container.update_attributes(params[:container])
        if (response = start_container)
          @container.uuid = response.id
        else
          process_error(:object => @container.compute_resource, :render => 'environment')
          return
        end
      end
      render_wizard @container
    end

    private

    def update_or_create_repo(name, registry_id)
      registry_id = nil if registry_id.blank?
      DockerRepository.find_or_create_by_name_and_docker_registry_id!(name, registry_id)
    end

    def finish_wizard_path
      container_path(:id => params[:container_id])
    end

    def allowed_resources
      ComputeResource.authorized(:view_compute_resources)
    end

    def find_container
      @container = Container.find(params[:container_id])
    rescue ActiveRecord::RecordNotFound
      not_found
    end

    def start_container
      @container.compute_resource.create_container(@container.parametrize)
    end
  end
end
