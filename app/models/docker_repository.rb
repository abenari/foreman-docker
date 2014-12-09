class DockerRepository < ActiveRecord::Base
  has_many :tags, :class_name => 'DockerTag', :foreign_key => 'docker_repository_id',
                  :dependent  => :destroy
  has_many :containers
  belongs_to :registry, :class_name => 'DockerRegistry', :foreign_key => 'docker_registry_id'

  attr_accessible :name

  validates :name, :presence => true, :uniqueness => { :scope => :docker_registry_id }
end
