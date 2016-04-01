# To be replaced by find_resource, FindCommon after 1.6 support is deprecated
module ForemanDocker
  module ContainerDeletion
    def container_deletion
      # Unmanaged container - only present in Compute Resource
      if params[:compute_resource_id].present?
        @deleted_identifier = params[:id]
        destroy_compute_resource_vm(params[:compute_resource_id], params[:id])
      else # Managed container
        find_container
        @deleted_identifier = @container.name

        destroy_compute_resource_vm(@container.compute_resource, @container.uuid) &&
          @container.destroy
      end
    end

    def destroy_compute_resource_vm(resource_id, uuid)
      @container_resource = ComputeResource.authorized(:destroy_compute_resources_vms)
                            .find(resource_id)
      @container_resource.destroy_vm(uuid)
    rescue => error
      logger.error "#{error.message} (#{error.class})\n#{error.backtrace.join("\n")}"
      false
    end
  end
end
