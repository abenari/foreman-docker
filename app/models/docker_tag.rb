class DockerTag < ActiveRecord::Base
  belongs_to :repository, :class_name => 'DockerRepository', :foreign_key => 'docker_repository_id'

  attr_accessible :tag, :repository

  validates :tag, :presence => true, :uniqueness => { :scope => :docker_repository_id }
  validates :repository, :presence => true
end
