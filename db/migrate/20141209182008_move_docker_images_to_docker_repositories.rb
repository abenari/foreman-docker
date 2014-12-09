class MoveDockerImagesToDockerRepositories < ActiveRecord::Migration
  def change
    remove_foreign_key :docker_tags, :name => :docker_tags_docker_image_id_fk
    remove_foreign_key :containers, :name => :containers_docker_image_id_fk
    drop_table :docker_image_docker_registries

    rename_table :docker_images, :docker_repositories

    rename_column :docker_repositories, :image_id, :name
    rename_column :containers,  :docker_image_id, :docker_repository_id
    rename_column :docker_tags, :docker_image_id, :docker_repository_id
    add_column :docker_repositories, :docker_registry_id, :integer

    add_foreign_key :docker_tags, :docker_repositories
    add_foreign_key :containers, :docker_repositories
  end
end
