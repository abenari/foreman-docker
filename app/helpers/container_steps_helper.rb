module ContainerStepsHelper
  def container_wizard(step)
    wizard_header(
      step,
      _('Resource'),
      _('Image'),
      _('Configuration'),
      _('Environment')
    )
  end

  def select_registry(f)
    field(f, 'repository[registry_id]', :label => _("Registry")) do
      collection_select :repository, :registry_id,
                        DockerRegistry.with_taxonomy_scope_override(@location, @organization)
                          .authorized(:view_registries),
                        :id, :name,
                        { :prompt => _("Select a registry") },
                        :class => "form-control", :disabled => f.object.repository.present?
    end
  end
end
