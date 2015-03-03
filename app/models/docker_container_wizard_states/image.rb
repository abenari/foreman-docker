module DockerContainerWizardStates
  class Image < ActiveRecord::Base
    self.table_name_prefix = 'docker_container_wizard_states_'
    belongs_to :wizard_state, :class_name => DockerContainerWizardState,
                              :foreign_key => :docker_container_wizard_state_id
    delegate :compute_resource_id, :to => :wizard_state

    validates :tag,             :presence => true
    validates :repository_name, :presence => true

    def image=(image)
      if (data = image.match(/\A([a-z0-9_\/\-.]+)(?::([a-z0-9_\-.]+))?\z/))
        self.repository_name = data[1]
        self.tag = data[2] || "latest"
      else
        raise ForemanDocker::InvalidImageFormat
      end
    end
  end
end
